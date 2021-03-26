defmodule PappapWeb.ConnectionCheckController do
  use PappapWeb, :controller
  use Common.Tools

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

    case map do
      %{"result" => false} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end
end
