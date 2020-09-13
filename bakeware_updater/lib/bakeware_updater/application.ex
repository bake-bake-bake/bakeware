defmodule BakewareUpdater.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      BakewareUpdater.RequestManager,
      BakewareUpdater.AutoUpdater
    ]

    opts = [strategy: :one_for_one, name: BakewareUpdater.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
