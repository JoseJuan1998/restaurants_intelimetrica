# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :restaurants,
  ecto_repos: [Restaurants.Repo]

config :restaurants, Restaurants.Repo,
  migration_primary_key: [type: :uuid],
  migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :restaurants, RestaurantsWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Phoenix.Endpoint.Cowboy2Adapter,
  render_errors: [
    formats: [json: RestaurantsWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Restaurants.PubSub,
  live_view: [signing_salt: "8tFx3d8y"]

config :restaurants, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: RestaurantsWeb.Router,
      # (optional) endpoint config used to set host, port and https schemes.
      endpoint: RestaurantsWeb.Endpoint
    ]
  }

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :restaurants, Restaurants.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
