# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

#database_url =
#  System.get_env("DATABASE_URL") ||
#    raise """
#    environment variable DATABASE_URL is missing.
#    For example: ecto://USER:PASS@HOST/DATABASE
#    """
#
#config :pappap, Pappap.Repo,
#  # ssl: true,
#  url: database_url,
#  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
#
#secret_key_base =
#  System.get_env("SECRET_KEY_BASE") ||
#    raise """
#    environment variable SECRET_KEY_BASE is missing.
#    You can generate one by calling: mix phx.gen.secret
#    """

config :pappap, Pappap.Repo,
  username: "postgres",
  password: "postgres",
  database: "pappapdb",
  socket_dir: "/tmp/cloudsql/e-players6814:asia-northeast1:pappapdb",
  pool_size: 10

config :pappap, PappapWeb.Endpoint,
  load_from_system_env: true,
  http: [port: {:system, "PORT"}],
  check_origin: false,
  server: true,
  root: ".",
  secret_key_base: "jNdYCx7OQTVpeGd5gH2Mto+spavwuG6RzMFE4+UAH/QgP8C5EP4BLcVCyWSkv+TI"

config :pigeon, :apns,
  apns_default: %{
    key: "lib/pappap-0.1.0/priv/cert/AuthKey_5KHYB5J926.p8",
    key_identifier: "5KHYB5J926",
    team_id: "32B5DRP9TS",
    mode: :prod
  }
config :pappap, :db_domain_url, "https://dbserver-dot-e-players6814.an.r.appspot.com"

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :pappap, PappapWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.

config :pappap, :db_domain_url, "http://34.84.71.145"
