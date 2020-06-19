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
  secret_key_base: "8fuPDy13wpGVWNny4IkgZ+cy4ZzWRvBBmHmbPsRgMPBVhtyPMkpWkHW17YfRJE1D",
  render_errors: [view: PappapWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Pappap.PubSub,
  live_view: [signing_salt: "AQTgcwja"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
