defmodule Bakeware do
  @doc """
  Assembler function to be used as a Mix release step

  #{
    File.read!("README.md")
    |> String.split(~r/<!-- ASSEMBLE !-->/)
    |> Enum.drop(1)
    |> hd()
  }
  """
  defdelegate assemble(release), to: Bakeware.Assembler
end
