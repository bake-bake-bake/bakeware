defmodule SousChef.Repo do
  use Ecto.Repo,
    otp_app: :sous_chef,
    adapter: Ecto.Adapters.Postgres
end
