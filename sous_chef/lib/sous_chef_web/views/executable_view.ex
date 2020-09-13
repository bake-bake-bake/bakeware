defmodule SousChefWeb.ExecutableView do
  use SousChefWeb, :view
  alias SousChefWeb.ExecutableView

  def render("index.json", %{executables: executables}) do
    render_many(executables, ExecutableView, "executable.json")
  end

  def render("show.json", %{executable: executable}) do
    render_one(executable, ExecutableView, "executable.json")
  end

  def render("executable.json", %{executable: executable}) do
    %{
      id: executable.id,
      name: executable.name,
      active: executable.active,
      versions: executable.versions,
      type: executable.type
    }
  end
end
