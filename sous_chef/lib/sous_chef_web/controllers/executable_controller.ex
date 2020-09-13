defmodule SousChefWeb.ExecutableController do
  use SousChefWeb, :controller

  alias SousChef.Executable

  action_fallback SousChefWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.json", executables: SousChef.executables())
  end

  def create(conn, executable_params) do
    with {:ok, %Executable{} = executable} <- SousChef.create_executable(executable_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", Routes.executable_path(conn, :show, executable))
      |> render("show.json", executable: executable)
    end
  end

  def show(conn, %{"name" => name, "type" => type}) do
    with executable = %{} <- SousChef.find_executable(name, type) do
      render(conn, "show.json", executable: executable)
    end
  end

  def update(conn, %{"name" => name, "type" => type} = executable_params) do
    with executable = %{} <- SousChef.find_executable(name, type),
         {:ok, %Executable{} = executable} <-
           SousChef.update_executable(executable, executable_params) do
      render(conn, "show.json", executable: executable)
    end
  end

  def delete(conn, %{"name" => name, "type" => type}) do
    with executable = %{} <- SousChef.find_executable(name, type),
         {:ok, %Executable{}} <- SousChef.delete_executable(executable) do
      send_resp(conn, :no_content, "")
    end
  end

  def check(conn, %{"name" => name, "version" => version, "type" => type}) do
    with exec = %{} <- SousChef.find_executable(name, type),
         {:ok, version} <- Version.parse(version) do
      # Do we need to support downgrades as well?
      if Version.compare(version, exec.active) == :lt do
        json(conn, %{status: "update", url: download_url(exec), version: exec.active})
      else
        json(conn, :ok)
      end
    end
  end

  defp download_url(exec) do
    "https://bakeware.s3.us-east-2.amazonaws.com/binaries/#{exec.name}-#{exec.version}-#{
      exec.type
    }"
  end
end
