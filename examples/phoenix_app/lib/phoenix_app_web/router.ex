defmodule PhoenixAppWeb.Router do
  use PhoenixAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixAppWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixAppWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  import Phoenix.LiveDashboard.Router

  scope "/" do
    pipe_through :browser
    live_dashboard "/dashboard", metrics: PhoenixAppWeb.Telemetry
  end
end
