defmodule SimpleEvalTest do
  use ExUnit.Case
  doctest SimpleEval

  test "greets the world" do
    assert SimpleEval.hello() == :world
  end
end
