defmodule Pappap.Repo do
  use Ecto.Repo,
    otp_app: :pappap,
    adapter: Ecto.Adapters.Postgres
end
