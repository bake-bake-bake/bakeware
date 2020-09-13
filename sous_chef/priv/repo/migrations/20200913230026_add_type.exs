defmodule SousChef.Repo.Migrations.AddType do
  use Ecto.Migration

  def change do
    alter table(:executables) do
      add :type, :string
    end

    drop unique_index(:executables, :name)
    create unique_index(:executables, [:name, :type])
  end
end
