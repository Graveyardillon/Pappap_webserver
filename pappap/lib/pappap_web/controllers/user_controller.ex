defmodule PappapWeb.UserController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @get_url "/user/get"

  def get(conn, params) do
    map =
      @db_domain_url <> @api_url <> @get_url
      |> send_json(params)

    json(conn, map)
  end
end