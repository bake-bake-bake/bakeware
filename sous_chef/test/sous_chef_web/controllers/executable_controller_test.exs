defmodule SousChefWeb.ExecutableControllerTest do
  use SousChefWeb.ConnCase

  alias SousChef.Updates
  alias SousChef.Updates.Executable

  @create_attrs %{
    active: "some active",
    name: "some name",
    versions: []
  }
  @update_attrs %{
    active: "some updated active",
    name: "some updated name",
    versions: []
  }
  @invalid_attrs %{active: nil, name: nil, versions: nil}

  def fixture(:executable) do
    {:ok, executable} = Updates.create_executable(@create_attrs)
    executable
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all executables", %{conn: conn} do
      conn = get(conn, Routes.executable_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create executable" do
    test "renders executable when data is valid", %{conn: conn} do
      conn = post(conn, Routes.executable_path(conn, :create), executable: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.executable_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => "some active",
               "name" => "some name",
               "versions" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.executable_path(conn, :create), executable: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update executable" do
    setup [:create_executable]

    test "renders executable when data is valid", %{
      conn: conn,
      executable: %Executable{id: id} = executable
    } do
      conn =
        put(conn, Routes.executable_path(conn, :update, executable), executable: @update_attrs)

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.executable_path(conn, :show, id))

      assert %{
               "id" => id,
               "active" => "some updated active",
               "name" => "some updated name",
               "versions" => []
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, executable: executable} do
      conn =
        put(conn, Routes.executable_path(conn, :update, executable), executable: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete executable" do
    setup [:create_executable]

    test "deletes chosen executable", %{conn: conn, executable: executable} do
      conn = delete(conn, Routes.executable_path(conn, :delete, executable))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.executable_path(conn, :show, executable))
      end
    end
  end

  defp create_executable(_) do
    executable = fixture(:executable)
    %{executable: executable}
  end
end
