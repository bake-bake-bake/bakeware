defmodule NifScript do
  use Bakeware.Script

  @impl Bakeware.Script
  def main([left, right]) do
    result = NifScript.Nif.add(String.to_integer(left), String.to_integer(right))
    IO.puts("#{left} + #{right} = #{result}")
    :ok
  end

  def main(args) do
    IO.warn("Unexpected arguments: #{inspect(args)}")
  end
end
