# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :sous_chef,
  ecto_repos: [SousChef.Repo]

# Configures the endpoint
config :sous_chef, SousChefWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "sZiESmmUFAEUr/OEj7gZnRfZQcnasHFW/Y0wnVBsf12E8lumyqBvJqRPH8rEIbjq",
  render_errors: [view: SousChefWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SousChef.PubSub,
  live_view: [signing_salt: "qtjS+KBZ"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
