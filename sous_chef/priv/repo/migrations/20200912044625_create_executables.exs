defmodule SousChef.Repo.Migrations.CreateExecutables do
  use Ecto.Migration

  def change do
    create table(:executables) do
      add :name, :string
      add :active, :string
      add :versions, {:array, :string}

      timestamps()
    end

    create unique_index(:executables, :name)
  end
end
