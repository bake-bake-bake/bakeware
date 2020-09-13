defmodule SimpleEval do
  use Bakeware.Script

  def main([eval]) do
    Code.eval_string(eval)
    0
  end

  def main(_) do
    raise ArgumentError, "Unknown arguments. Try wrapping in double quotes"
  end
end
