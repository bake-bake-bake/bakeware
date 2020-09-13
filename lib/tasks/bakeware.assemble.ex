defmodule Mix.Tasks.Bakeware.Assemble do
  use Mix.Task

  @switches [
    path: :string,
    name: :string
  ]

  @shortdoc "Manually assemble bakeware executable"
  @doc """
  Manually assemble bakeware executable

  #{
    File.read!("README.md")
    |> String.split(~r/<!-- ASSEMBLE_TASK !-->/)
    |> Enum.drop(1)
    |> hd()
  }
  """
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: @switches)
    config = Mix.Project.config()
    name = opts[:name] || config[:app]
    path = opts[:path] || Path.join(Mix.Project.build_path(), "rel/#{name}")
    Bakeware.Assembler.assemble(path, name)
  end
end
