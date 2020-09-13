defmodule BakewareUpdater.AutoUpdater do
  use GenServer

  alias BakewareUpdater.DownloadManager

  require Logger

  defmodule State do
    defstruct [:downloader, :exec_path, :name]
  end

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    exec_path = System.get_env("BAKEWARE_EXECUTABLE")
    name = System.get_env("RELEASE_NAME")

    next =
    if exec_path && name, do: {:continue, :autoupdate}, else: :hibernate

    {:ok, %State{exec_path: exec_path, name: name}, next}
  end

  @impl GenServer
  def handle_continue(:autoupdate, state) do
    version = state.name
    |> String.to_atom()
    |> Application.spec()
    |> Keyword.get(:vsn)

    with %{"url" => url} <- BakewareUpdater.check_for_update(state.name, version, 5000),
          {:ok, downloader} <- DownloadManager.start(uri: URI.parse(url))
     do
      {:noreply, %{state | downloader: downloader}}
     else
      err -> log_error(err)
    end

  catch
    :error, reason -> log_error(reason)
    :exit, reason -> log_error(reason)
    err -> log_error(err)
  end

  @impl GenServer
  def handle_info({DownloadManager, :complete, new_exec}, state) do
    Logger.info("[BakewareUpdater] Applying Update")
    _ = File.cp!(new_exec, state.exec_path)
    _ = File.chmod!(state.exec_path, 0o755)

    Logger.info("[BakewareUpdater] Successfully updated. Restarting...")

    # Super hackey, but we essentially replace the old executable here
    # then spawn a port of the new version, then kill this old running
    # version. The new port open is left up as a zombie...
    _ = Port.open({:spawn_executable, state.exec_path}, [args: bakeware_args()])
    :timer.sleep(500)
    :erlang.halt()
  end

  defp bakeware_args() do
    {argc, ""} = Integer.parse(System.get_env("BAKEWARE_ARGC"))

    if argc > 0 do
      for v <- 1..argc, do: System.get_env("BAKEWARE_ARG#{v}")
    else
      []
    end
  end

  defp log_error(err) do
    Logger.warn("[BakewareUpdater] Ignoring failed auto update attempt - #{inspect(err)}")
    {:noreply, :hibernate}
  end
end
