defmodule SousChef.Executable do
  use Ecto.Schema

  import Ecto.Changeset

  schema "executables" do
    field :active, :string
    field :name, :string
    field :versions, {:array, :string}, default: []

    timestamps()
  end

  def changeset(exec \\ %__MODULE__{}, attrs) do
    exec
    |> cast(attrs, [:active, :name, :versions])
    |> validate_required([:name])
    |> validate_change(:active, &validate_version/2)
    |> validate_change(:versions, &validate_versions/2)
    |> unique_constraint(:name)
  end

  defp validate_version(field, ver) do
    case Version.parse(ver) do
      :error -> [{field, "invalid version #{ver}"}]
      {:ok, _ver} -> []
    end
  end

  defp validate_versions(field, vers) do
    Enum.flat_map(vers, &validate_version(field, &1))
  end
end
