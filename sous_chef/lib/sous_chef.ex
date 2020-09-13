defmodule SousChef do
  alias SousChef.{Executable, Repo}

  def create_executable(attrs) do
    Executable.changeset(attrs)
    |> Repo.insert()
  end

  def delete_executable(executable) do
    Repo.delete(executable)
  end

  def executables(), do: Repo.all(Executable)

  def find_executable(name, type) do
    Repo.get_by(Executable, name: name, type: type) || {:error, :not_found}
  end

  def update_executable(exec, attrs) do
    Executable.changeset(exec, attrs)
    |> Repo.update()
  end
end
