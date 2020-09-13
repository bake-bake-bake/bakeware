defmodule SimpleApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    IO.puts("Hello, OTP Application!")

    IO.puts("Exiting...")
    :erlang.halt()

    children = [
      # Starts a worker by calling: SimpleApp.Worker.start_link(arg)
      # {SimpleApp.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SimpleApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
