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
        {argc, ""} = Integer.parse(System.get_env("BAKEWARE_ARGC"))

        args =
          if argc > 0 do
            for v <- 1..argc, do: System.get_env("BAKEWARE_ARG#{v}")
          else
            []
          end

        main(args)
        |> result_to_halt()
        |> :erlang.halt()
      catch
        error, reason ->
          IO.warn(
            "Caught exception in main/1: #{inspect(error)} => #{inspect(reason, pretty: true)}",
            __STACKTRACE__
          )

          :erlang.halt(1)
      end

      defp result_to_halt(:ok), do: 0
      defp result_to_halt(:error), do: 1
      defp result_to_halt(:abort), do: :abort
      defp result_to_halt(status) when is_integer(status) and status >= 0, do: status
      defp result_to_halt(status) when is_list(status), do: status
      defp result_to_halt(status) when is_binary(status), do: to_charlist(status)

      defp result_to_halt(unknown),
        do: raise("Invalid return value from #{__MODULE__}.main/1: #{inspect(unknown)}")
    end
  end
end
