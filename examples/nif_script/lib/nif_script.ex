defmodule NifScript do
  use Bakeware.Script

  @impl Bakeware.Script
  def main([left, right]) do
    result = NifScript.Nif.add(String.to_integer(left), String.to_integer(right))
    IO.puts("#{left} + #{right} = #{result}")
    :ok
  end

  def main(_args) do
    IO.puts("Try calling with two integer arguments")
    :error
  end
end
