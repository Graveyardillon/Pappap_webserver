defmodule PappapWeb.SyncController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @sync_url "/sync"

  def sync(conn, params) do
    @db_domain_url <> @api_url <> @sync_url
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end
end
