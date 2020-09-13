defmodule BakewareUpdater.DownloadManager do
  use GenServer

  require Logger

  defmodule State do
    defstruct caller: nil,
              conn: nil,
              downloaded: 0,
              dl_progress: 0,
              fd: nil,
              file_name: nil,
              file_size: nil,
              request_ref: nil,
              request_status: nil,
              response_headers: [],
              status: :idle,
              uri: nil
  end

  def start(args) do
    args = Keyword.put(args, :caller, self())
    GenServer.start(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(args) do
    {:ok, fd, file_name} = Temp.open()
    Temp.track!()

    state =
      struct(State, args)
      |> Map.put(:fd, fd)
      |> Map.put(:file_name, file_name)

    {:ok, state, {:continue, :start_download}}
  end

  @impl GenServer
  def handle_continue(:start_download, %{uri: uri} = state) do
    with {:ok, conn} <-
           Mint.HTTP.connect(String.to_existing_atom(uri.scheme), uri.host, state.uri.port),
         {:ok, conn, request_ref} <-
           Mint.HTTP.request(conn, "GET", "#{uri.path}?#{uri.query}", [], nil) do
      {:noreply, %{state | conn: conn, request_ref: request_ref}}
    else
      {:error, err} -> {:stop, err, state}
      {:error, _conn, err} -> {:stop, err, state}
    end
  end

  @impl GenServer
  def handle_info(message, state) do
    case Mint.HTTP.stream(state.conn, message) do
      :unknown ->
        Logger.warn("[DownloadManager] - Unknown message - #{inspect(message)}")
        {:noreply, state}

      {:error, _conn, %{reason: :closed}, _} ->
        Logger.warn("[DownloadManager] - conn closed")
        {:noreply, state}

      {:error, _conn, err, _responses} ->
        Logger.error("[DownloadManager] - Download failed: #{inspect(err.reason)}")
        {:stop, err, state}

      {:ok, conn, responses} ->
        handle_responses(%{state | conn: conn}, responses)
    end
  end

  @impl GenServer
  def terminate(_reason, state) do
    Logger.info("[DownloadManager] - Cleaning up Download files")
    _ = File.close(state.fd)
    # Temp.cleanup()
  end

  defp calc_progress(val, size), do: round(val * 100 / size)

  defp get_file_size(headers) do
    with {_, size_str} <- Enum.find(headers, &match?({"content-length", _}, &1)),
         {size, ""} <- Integer.parse(size_str) do
      size
    else
      # judicious default
      _err -> 100
    end
  end

  defp handle_responses(state, responses) do
    Enum.reduce(responses, state, &process_response/2)
    |> case do
      %{status: :download_complete} = state ->
        Mint.HTTP.close(state.conn)
        {:noreply, state, {:continue, :apply}}

      state ->
        {:noreply, state}
    end
  end

  defp process_response({:status, ref, status}, %{request_ref: ref} = state) do
    %{state | request_status: status}
  end

  defp process_response({:headers, ref, headers}, %{request_ref: ref} = state) do
    %{state | file_size: get_file_size(headers), response_headers: headers}
  end

  defp process_response({:data, ref, data}, %{request_ref: ref} = state) do
    IO.binwrite(state.fd, data)
    downloaded = state.downloaded + byte_size(data)
    dl_progress = calc_progress(downloaded, state.file_size)
    %{state | downloaded: downloaded, dl_progress: dl_progress}
  end

  defp process_response({:done, ref}, %{request_ref: ref} = state) do
    Logger.info("[UpdateManager] - download complete")
    File.close(state.fd)

    send state.caller, {__MODULE__, :complete, state.file_name}
    %{state | status: :download_complete}
  end
end
