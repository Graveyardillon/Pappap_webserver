defmodule PappapWeb.EntrantController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url) <> "/api"
  @entrant_url "/entrant"
  @entrant_log_url "/entrant_log"
  @rank_url "/rank"

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/entrant/" <> path
      |> get_parammed_request(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
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
      @db_domain_url <> "/api/entrant/" <> path
      |> send_json(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Pass a delete request to database server.
  """
  def pass_delete_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/entrant/" <> path
      |> delete_request(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  def create(conn, params) do
    map =
      @db_domain_url <> @entrant_url
      |> send_json(params)

    if map["result"] do
      @db_domain_url <> @entrant_log_url
      |> send_json(map)
    end

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  def show_rank(conn, %{"tournament_id" => tournament_id, "user_id" => user_id}) do
    map =
      @db_domain_url <> @entrant_url <> @rank_url <> "/" <> to_string(tournament_id) <> "/" <> to_string(user_id)
      |> get_request()

      case map do
        %{"result" => false, "reason" => _reason} ->
          conn
          |> put_status(500)
          |> json(map)
        map ->
          json(conn, map)
      end
  end
end
