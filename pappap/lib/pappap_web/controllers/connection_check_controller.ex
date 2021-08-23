defmodule PappapWeb.ConnectionCheckController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @connection_check "/check/connection"

  @doc """
  Checks if the server is available.
  """
  def connection_check(conn, _params) do
    map =
    @db_domain_url <> @api_url <> @connection_check
    |> get_request()
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end
end
