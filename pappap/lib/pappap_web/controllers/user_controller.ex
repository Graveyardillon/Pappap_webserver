defmodule PappapWeb.UserController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @get_url "/user/get"
  @get_with_room_id_url "/chat_room/private_room"

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/user/" <> path
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
      @db_domain_url <> "/api/user/" <> path
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

  def get(conn, %{"id" => id}) do
    map =
      @db_domain_url <> @api_url <> @get_url <> "?id=" <> to_string(id)
      |> get_request()

    json(conn, map)
  end

  def get_with_room_id(conn, %{"my_id" => my_id, "partner_id" => partner_id}) do
    map =
      @db_domain_url <> @api_url <> @get_with_room_id_url <> "?my_id=" <> to_string(my_id) <> "&partner_id=" <> partner_id
      |> get_request()

    json(conn, map)
  end
end
