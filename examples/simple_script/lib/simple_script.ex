defmodule SimpleScript do
  use Bakeware.Script

  @impl Bakeware.Script
  def main(arg0, args) do
    argc = length(args)

    args_print =
      if argc > 0 do
        for v <- 1..argc, do: "\narg#{v}=" <> Enum.at(args, v - 1)
      end

    IO.puts("""
    argc=#{length(args)}
    arg0=#{arg0}#{args_print}
    """)

    0
  end
end
