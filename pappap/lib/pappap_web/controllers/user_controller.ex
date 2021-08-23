defmodule PappapWeb.UserController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @get_url "/user/get"
  @get_with_room_id_url "/chat_room/private_room"

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/user/" <> path
    |> get_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Pass a post request to database server.
  """
  def pass_post_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/user/" <> path
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  def pass_delete_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/user/" <> path
    |> delete_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  def get(conn, %{"id" => id}) do
    @db_domain_url <> @api_url <> @get_url <> "?id=" <> to_string(id)
    |> get_request()
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  def get_with_room_id(conn, %{"my_id" => my_id, "partner_id" => partner_id}) do
    @db_domain_url <> @api_url <> @get_with_room_id_url <> "?my_id=" <> to_string(my_id) <> "&partner_id=" <> partner_id
    |> get_request()
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  def report(conn, params) do
    @db_domain_url <> "/api/user_report"
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end
end
