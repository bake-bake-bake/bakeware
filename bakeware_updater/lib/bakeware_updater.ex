defmodule BakewareUpdater do
  use GenServer

  require Logger

  defmodule State do
    defstruct conn: nil,
              data: "",
              from: nil,
              request_ref: nil,
              request_status: nil,
              response_headers: [],
              status: :idle
  end

  def start_link(args) do
    GenServer.start(__MODULE__, args, name: __MODULE__)
  end

  @doc """
  Check the default update server for an executable update
  """
  @spec check(exec_name :: binary(), current_version :: binary(), timeout :: non_neg_integer()) ::
          binary() | map()
  def check(exec_name, version, timeout \\ 5000) do
    # Use default update server
    # TODO: Support passing URI to hit other update server?
    uri = URI.parse("https://sous-chef.jonjon.dev/api/check/#{exec_name}?version=#{version}")
    GenServer.call(__MODULE__, {:check, uri}, timeout)
  end

  @impl GenServer
  def init(_args) do
    {:ok, %State{}}
  end

  @impl GenServer
  def handle_call({:check, uri}, from, state) do
    with {:ok, conn} <-
           Mint.HTTP.connect(String.to_existing_atom(uri.scheme), uri.host, uri.port),
         {:ok, conn, request_ref} <-
           Mint.HTTP.request(conn, "GET", "#{uri.path}?#{uri.query}", [], nil) do
      {:noreply, %{state | conn: conn, request_ref: request_ref, from: from}}
    else
      {:error, err} -> {:reply, err, state}
      {:error, _conn, err} -> {:reply, err, state}
    end
  end

  @impl GenServer
  def handle_info(message, state) do
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        Logger.warn("[BakewareUpdater] - Unknown message - #{inspect(message)}")
        {:noreply, state}

      {:error, _conn, %{reason: :closed}, _} ->
        Logger.warn("[BakewareUpdater] - conn closed")
        {:noreply, state}

      {:error, _conn, err, _responses} ->
        Logger.error("[BakewareUpdater] - failed: #{inspect(err.reason)}")
        {:stop, err, state}

      {:ok, conn, responses} ->
        handle_responses(%{state | conn: conn}, responses)
    end
  end

  defp handle_responses(state, responses) do
    Enum.reduce(responses, state, &process_response/2)
    |> case do
      %{status: :done, data: data} ->
        GenServer.reply(state.from, Jason.decode!(data))
        Mint.HTTP.close(state.conn)
        {:noreply, %State{}}

      _ ->
        {:noreply, state}
    end
  end

  defp process_response({:status, ref, status}, %{request_ref: ref} = state) do
    %{state | request_status: status}
  end

  defp process_response({:headers, ref, headers}, %{request_ref: ref} = state) do
    %{state | response_headers: headers}
  end

  defp process_response({:data, ref, data}, %{request_ref: ref} = state) do
    %{state | data: state.data <> data}
  end

  defp process_response({:done, ref}, %{request_ref: ref} = state) do
    Logger.debug("[UpdateManager] - request complete")
    %{state | status: :done}
  end
end
