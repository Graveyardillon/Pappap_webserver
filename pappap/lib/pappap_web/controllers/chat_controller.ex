defmodule PappapWeb.ChatController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url "http://localhost:4000"
  @api_url "/api"
  @chat_room_url "/chat_room"
  @chat_room_log_url "/chat_room_log"
  @content_type [{"Content-Type", "application/json"}]

  def create_chatroom(conn, params) do
    map =
      @db_domain_url <> @api_url <> @chat_room_url
      |>sendHTTP(params, @content_type)
    @db_domain_url <> @api_url <> @chat_room_log_url
    |>sendHTTP(map, @content_type)
    json(conn, map)
  end
end