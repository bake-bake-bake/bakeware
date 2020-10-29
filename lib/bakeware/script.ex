defmodule Bakeware.Script do
  @moduledoc """
  Helper to generate a script that takes command-line arguments

  #{
    File.read!("README.md")
    |> String.split(~r/<!-- SCRIPT !-->/)
    |> Enum.drop(1)
    |> hd()
  }
  """

  @type args :: [String.t()]

  @callback main(args) ::
              :ok | :error | non_neg_integer() | :abort | charlist() | String.t()

  @doc "Defines an app spec that will execute a `script`"
  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour Bakeware.Script
      import Bakeware.Script, only: [get_argc!: 0, get_args: 1, result_to_halt: 1]

      use Application

      def start(_type, _args) do
        children = [
          %{id: Task, restart: :temporary, start: {Task, :start_link, [&__MODULE__._main/0]}}
        ]

        opts = [strategy: :one_for_all, name: __MODULE__.Supervisor]
        Supervisor.start_link(children, opts)
      end

      @doc false
      def _main() do
        get_argc!()
        |> get_args()
        |> main()
        |> result_to_halt()
        |> :erlang.halt()
      catch
        error, reason ->
          IO.warn(
            "Caught exception in #{__MODULE__}.main/1: #{inspect(error)} => #{
              inspect(reason, pretty: true)
            }",
            __STACKTRACE__
          )

          :erlang.halt(1)
      end
    end
  end

  defmacro get_argc!() do
    quote location: :keep do
      argc_str = System.get_env("BAKEWARE_ARGC", "0")

      case Integer.parse(argc_str) do
        {argc, ""} -> argc
        _ -> raise "Invalid BAKEWARE_ARGC - #{argc_str}"
      end
    end
  end

  defmacro get_args(argc) do
    quote location: :keep, bind_quoted: [argc: argc] do
      if argc > 0 do
        for v <- 1..argc, do: System.get_env("BAKEWARE_ARG#{v}")
      else
        []
      end
    end
  end

  defmacro result_to_halt(result) do
    quote location: :keep, bind_quoted: [result: result] do
      case result do
        :ok ->
          0

        :error ->
          1

        :abort ->
          :abort

        status when is_integer(status) and status >= 0 ->
          status

        status when is_list(status) ->
          status

        status when is_binary(status) ->
          to_charlist(status)

        unknown ->
          raise("Invalid return value from #{__MODULE__}.main/1: #{inspect(unknown)}")
      end
    end
  end
end
