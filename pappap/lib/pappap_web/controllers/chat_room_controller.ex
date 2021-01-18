defmodule PappapWeb.ChatRoomController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/chat_room/" <> path
      |> get_parammed_request(params)

    json(conn, map)
  end

  @doc """
  Pass a post request to database server.
  """
  def pass_post_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/chat_room/" <> path
      |> send_json(params)

    json(conn, map)
  end

  @doc """
  Show chat room.
  """
  def show(conn, params) do
    map =
      @db_domain_url <> "/api/chat_room"
      |> get_parammed_request(params)

    json(conn, map)
  end
end
