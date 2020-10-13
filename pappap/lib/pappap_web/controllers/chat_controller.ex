defmodule PappapWeb.ChatController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url "http://localhost:4000"
  @api_url "/api"
  @chats_url "/chat"
  @chats_log_url "/chat_log"
  @chat_room_url "/chat_room"
  @chat_room_log_url "/chat_room_log"
  @chat_member_url "/chat_member"
  @chat_member_log_url "/chat_member_log"
  @content_type [{"Content-Type", "application/json"}]

  def create_chatroom(conn, params) do
    map =
      @db_domain_url <> @api_url <> @chat_room_url
      |>sendHTTP(params, @content_type)
    @db_domain_url <> @api_url <> @chat_room_log_url
    |>sendHTTP(map, @content_type)
    json(conn, map)
  end
  def create_chats(conn, params) do
    map =
      @db_domain_url <> @api_url <> @chats_url
      |>sendHTTP(params, @content_type)
    index = 
    Map.get(map, "data")
    |>Map.get("index")
    merged_map =
      Map.get(params, "chat")
      |>Map.put("index", index)
      |>IO.inspect()
    @db_domain_url <> @api_url <> @chats_log_url
    |>sendHTTP(merged_map, @content_type)
    |>IO.inspect
    json(conn, map)
  end
  def create_chatmember(conn, params) do
    map =
      @db_domain_url <> @api_url <> @chat_member_url
      |>sendHTTP(params, @content_type)
    @db_domain_url <> @api_url <> @chat_member_log_url
    |>sendHTTP(map, @content_type)
    json(conn, map)
  end
end