defmodule PappapWeb.EntrantController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url) <> "/api"
  @entrant_url "/entrant"
  @entrant_log_url "/entrant_log"
  @rank_url "/rank"
  @entrant_delete_url "/entrant/delete"

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/entrant/" <> path
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

    @db_domain_url <> "/entrant/" <> path
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

    @db_domain_url <> "/entrant/" <> path
    |> delete_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  def create(conn, params) do
    @db_domain_url <> @entrant_url
    |> send_json(params)
    ~> response

    if response.body["result"] do
      @db_domain_url <> @entrant_log_url
      |> send_json(response.body)
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  def show_rank(conn, %{"tournament_id" => tournament_id, "user_id" => user_id}) do
    @db_domain_url <> @entrant_url <> @rank_url <> "/" <> to_string(tournament_id) <> "/" <> to_string(user_id)
    |> get_request()
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end
end
