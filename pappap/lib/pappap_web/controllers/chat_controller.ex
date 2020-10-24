defmodule PappapWeb.ChatController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url "http://localhost:4000"
  @api_url "/api"
  @chat_room_url "/chat_room"
  @chat_room_log_url "/chat_room_log"

  def create_chatroom(conn, params) do
    map =
      @db_domain_url <> @api_url <> @chat_room_url
      |> send_json(params)

    @db_domain_url <> @api_url <> @chat_room_log_url
    |> send_json(map)

    json(conn, map)
  end
end