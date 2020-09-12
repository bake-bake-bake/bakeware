defmodule SousChefWeb.PageController do
  use SousChefWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
