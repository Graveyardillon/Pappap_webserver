# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :pappap,
  ecto_repos: [Pappap.Repo]

# Configures the endpoint
config :pappap, PappapWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jNdYCx7OQTVpeGd5gH2Mto+spavwuG6RzMFE4+UAH/QgP8C5EP4BLcVCyWSkv+TI",
  render_errors: [view: PappapWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Pappap.PubSub,
  live_view: [signing_salt: "AQTgcwja"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

#Configuration for deployment.
#config :pigeon, :apns,
#  apns_default: %{
#    key: "lib/pappap-0.1.0/priv/cert/AuthKey_5KHYB5J926.p8",
#    key_identifier: "5KHYB5J926",
#    team_id: "32B5DRP9TS",
#    mode: :prod
#  }

config :pigeon, :apns,
  apns_default: %{
    key: "priv/cert/AuthKey_5KHYB5J926.p8",
    key_identifier: "5KHYB5J926",
    team_id: "32B5DRP9TS",
    mode: :dev
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

#config :pappap, :db_domain_url, "https://dbserver-dot-e-players6814.an.r.appspot.com"
config :pappap, :db_domain_url, "http://localhost:4000"
