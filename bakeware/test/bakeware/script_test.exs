defmodule Bakeware.ScriptTest do
  use ExUnit.Case, async: false

  alias Bakeware.Script

  describe "_main/1" do
    test "Should not require BAKEWARE_ARGC" do
      assert 0 == Script._main(fn _ -> :ok end)
    end

    test "Should return the expected halt status for each main_fn result" do
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
          assert status == Script._main(fn _ -> result end)
        end
      )
    end
  end
end
