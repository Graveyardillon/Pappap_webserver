defmodule PappapWeb.RelationController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @follow_url "/relation"
  @unfollow_url "/relation/unfollow"
  @list_url "/relation/following_list"
  @id_list_url "/relation/following_id_list"
  @followers_list "/relation/followers_list"
  @followers_id_list "/relation/followers_id_list"
  @content_type [{"Content-Type", "application/json"}]

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/relation/" <> path
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
      @db_domain_url <> "/api/relation/" <> path
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
