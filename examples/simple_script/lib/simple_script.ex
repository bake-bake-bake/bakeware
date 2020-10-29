defmodule SimpleScript do
  use Bakeware.Script

  @impl Bakeware.Script
  def main([]) do
    IO.puts("Pass me some arguments and I will upcase them if you specify --upcase")
  end

  def main(args) do
    args
    |> parse_args()
    |> response()
    |> IO.puts()
  end

  defp parse_args(args) do
    {opts, word, _} =
      args
      |> OptionParser.parse(switches: [upcase: :boolean])

    {opts, List.to_string(word)}
  end

  defp response({opts, word}) do
    if opts[:upcase], do: String.upcase(word), else: word
  end
end
