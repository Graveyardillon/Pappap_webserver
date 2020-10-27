defmodule PappapWeb.EntrantController do
  use PappapWeb, :controller
  use Common.Tools
  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @entrant_url "/entrant"
  @entrant_log_url "/entrant_log"
  @api_url "/api"

  def create(conn, params) do
    map =
      @db_domain_url <> @api_url <> @entrant_url
      |> send_json(params)

    if map["result"] do
      @db_domain_url <> @api_url <> @entrant_log_url
      |> send_json(map)
      |> IO.inspect
    end
    
    json(conn, map)
  end
end