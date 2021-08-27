defmodule PappapWeb.NotificationController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url)

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/notification/" <> path
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

    @db_domain_url <> "/api/notification/" <> path
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Pass a delete request to database server.
  """
  def pass_delete_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/notification/" <> path
    |> delete_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end
end
