defmodule Bakeware.ScriptTest do
  use ExUnit.Case, async: true

  alias Bakeware.Script

  defmodule MockScript do
    use Script

    def main(_args), do: :ok
  end

  test "get_argc!/0" do
    System.delete_env("BAKEWARE_ARGC")
    assert 0 == MockScript.get_argc!()
  end

  test "get_args/1" do
    envs = [
      "There's a",
      "snake",
      "in my",
      "boot!"
    ]

    for {v, i} <- Enum.with_index(envs, 1), do: System.put_env("BAKEWARE_ARG#{i}", v)

    assert envs == MockScript.get_args(length(envs))
  end

  test "result_to_halt/1" do
    status_int = :random.uniform(10)

    Enum.each(
      [
        {:ok, 0},
        {:error, 1},
        {:abort, :abort},
        {status_int, status_int},
        {[status_int, status_int], [status_int, status_int]},
        {"asdf", 'asdf'}
      ],
      fn {result, status} ->
        assert status == MockScript.result_to_halt(result)
      end
    )
  end
end
