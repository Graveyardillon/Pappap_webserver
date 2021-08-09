defmodule PappapWeb.ProfileController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/profile/" <> path
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
    IO.inspect(params, label: :params)
    path = params["string"]

    map =
      @db_domain_url <> "/api/profile/" <> path
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

  @doc """
  Show profile
  """
  def show(conn, params) do
    map =
      @db_domain_url <> "/api/profile"
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
  Updates an icon.
  """
  def update_icon(conn, params) do
    file_path = unless params["image"] == "" do
      uuid = SecureRandom.uuid()
      File.cp(params["image"].path, "./static/image/tmp/#{uuid}.jpg")
      "./static/image/tmp/"<>uuid<>".jpg"
    end

    map =
      @db_domain_url <> "/api/profile/update_icon"
      |> send_profile_multipart(params, file_path)

    unless params["image"] == "", do: File.rm(file_path)

    json(conn, map)
  end
end
