defmodule PappapWeb.UserController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @get_url "/user/get"
  @get_with_room_id_url "/chat_room/private_room"

  def get(conn, params) do
    map =
      @db_domain_url <> @api_url <> @get_url
      |> send_json(params)

    json(conn, map)
  end

  def get_with_room_id(conn, params) do
    map =
      @db_domain_url <> @api_url <> @get_with_room_id_url
      |> send_json(params)
    
    json(conn, map)
  end
end