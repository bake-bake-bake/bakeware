defmodule NifScriptTest do
  use ExUnit.Case
  doctest NifScript

  test "greets the world" do
    assert NifScript.hello() == :world
  end
end
