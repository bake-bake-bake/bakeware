defmodule NifScript.Nif do
  @on_load {:load_nif, 0}
  @compile {:autoload, false}

  @doc false
  def load_nif() do
    nif_binary = Application.app_dir(:nif_script, "priv/script_nif")

    :erlang.load_nif(to_charlist(nif_binary), 0)
  end

  @doc "add 2 integers"
  def add(_left, _right), do: :erlang.nif_error(:nif_not_loaded)
end
