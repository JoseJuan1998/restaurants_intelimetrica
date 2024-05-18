defmodule Restaurants.Repo do
  use Ecto.Repo,
    otp_app: :restaurants,
    adapter: Ecto.Adapters.Postgres
end
