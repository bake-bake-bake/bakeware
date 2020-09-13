defmodule SimpleScript do
  use Bakeware.Script

  def main(args \\ []) do
    IO.puts("Hello, world!")
  end
end
