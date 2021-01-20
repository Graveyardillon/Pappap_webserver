defmodule PappapWeb.GameController do
  use PappapWeb, :controller
  use Common.Tools

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/game/" <> path
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
      @db_domain_url <> "/api/game/" <> path
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
end
