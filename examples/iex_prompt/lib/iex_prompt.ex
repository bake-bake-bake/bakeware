defmodule IExPrompt do
  use Bakeware.Script

  def main(_) do
    # Wait forever
    receive do
      _ -> :ok
    end
  end
end
