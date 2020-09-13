defmodule AutoUpdate.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    IO.inspect Application.spec(:auto_update), label: "Application Spec:"

    children = [
      # Starts a worker by calling: AutoUpdate.Worker.start_link(arg)
      # {AutoUpdate.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AutoUpdate.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
