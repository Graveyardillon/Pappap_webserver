# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

config :pappap, PappapWeb.Endpoint,
  load_from_system_env: true,
  http: [port: {:system, "PORT"}],
  check_origin: false,
  server: true,
  root: ".",
  secret_key_base: "jNdYCx7OQTVpeGd5gH2Mto+spavwuG6RzMFE4+UAH/QgP8C5EP4BLcVCyWSkv+TI"

config :pigeon, :apns,
  apns_default: %{
    key: "lib/pappap-2.2.1/priv/cert/AuthKey_MHN824H499.p8",
    key_identifier: "MHN824H499",
    team_id: "6ZMC8WKZZQ",
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
