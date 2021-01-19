defmodule PappapWeb.ChatController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @chats_url "/chat"
  @chats_log_url "/chat_log"
  @chat_room_url "/chat_room"
  @chat_room_log_url "/chat_room_log"
  @chat_member_url "/chat_member"
  @chat_member_log_url "/chat_member_log"
  @private_rooms "/chat_room/private_rooms"
  @delete "/chat"

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/chat/" <> path
      |> get_parammed_request(params)

    case map do
      %{"result" => false, "reason" => reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Pass a post request to database server.
  """
  def pass_post_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/chat/" <> path
      |> send_json(params)

    case map do
      %{"result" => false, "reason" => reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Delete a chat.
  """
  def delete(conn, params) do
    map =
      @db_domain_url <> @api_url <> @delete
      |> delete_request(params)

    json(conn, map)
  end

  def create_chatroom(conn, params) do
    map =
      @db_domain_url <> @api_url <> @chat_room_url
      |> send_json(params)

    @db_domain_url <> @api_url <> @chat_room_log_url
    |> send_json(map)

    json(conn, map)
  end

  def create_chats(conn, params) do
    map =
      @db_domain_url <> @api_url <> @chats_url
      |> send_json(params)

    index =
      Map.get(map, "data")
      |> Map.get("index")

    merged_map =
      Map.get(params, "chat")
      |> Map.put("index", index)
      |> IO.inspect()

    @db_domain_url <> @api_url <> @chats_log_url
    |> send_json(merged_map)
    |> IO.inspect

    json(conn, map)
  end

  def create_chatmember(conn, params) do
    map =
      @db_domain_url <> @api_url <> @chat_member_url
      |> send_json(params)
    @db_domain_url <> @api_url <> @chat_member_log_url
    |> send_json(map)

    json(conn, map)
  end

  def private_rooms(conn, %{"user_id" => user_id}) do
    map =
      @db_domain_url <> @api_url <> @private_rooms <> "?user_id=" <> to_string(user_id)
      |> get_request()

    json(conn, map)
  end
end
