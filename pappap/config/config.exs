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

# remote_database = "https://raw.githubusercontent.com/matomo-org/device-detector/3.13.1/regexes"
# remote_shortcode = "https://raw.githubusercontent.com/matomo-org/device-detector/3.13.1"

# config :ua_inspector,
#   database_path: Application.app_dir(:ua_inspector, "priv"),
#   http_opts: [],
#   database_path: remote_database,
#   remote_path: [
#     bot: remote_database,
#     browser_engine: remote_database <> "/client",
#     client: remote_database <> "/client",
#     device: remote_database <> "/device",
#     os: remote_database,
#     short_code_map: remote_shortcode,
#     vendor_fragment: remote_database
#   ],
#   remote_release: "3.13.1",
#   startup_silent: false,
#   startup_sync: true,
#   yaml_file_reader: {:yamerl_constr, :file, [[:str_node_as_binary]]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
