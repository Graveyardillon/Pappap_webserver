defmodule PappapWeb.ProfileController do
  use PappapWeb, :controller
  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @profile_url  "/profile"
  @update_url "/update"
  @content_type [{"Content-Type", "application/json"}]

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/profile/" <> path
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
      @db_domain_url <> "/api/profile/" <> path
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

  def update(conn, params) do
    url = @db_domain_url <> @api_url <> @profile_url <> @update_url

    with {:ok, attrs} <- Poison.encode(params),
    {:ok, _response} <- HTTPoison.post(url, attrs, @content_type) do
        json(conn, %{msg: "Succeed"})
    end
  end

  def send(conn, params) do
    map =
      @db_domain_url <> "/api/profile"
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
