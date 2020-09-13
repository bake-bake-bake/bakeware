defmodule SimpleEval do
  use Bakeware.Script

  def main(_) do
    pid = IEx.start()
    Process.group_leader(self(), pid)
    Process.monitor(pid)

    receive do
      _ ->
        IO.warn("IEx Died")
        :ok
    end
  end
end
