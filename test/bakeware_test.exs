defmodule BakewareTest do
  use ExUnit.Case
  doctest Bakeware

  test "greets the world" do
    assert Bakeware.hello() == :world
  end
end
