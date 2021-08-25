defmodule PappapWeb.ProfileController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url)

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/profile/" <> path
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

    @db_domain_url <> "/api/profile/" <> path
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

    @db_domain_url <> "/api/profile/" <> path
    |> delete_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  def send(conn, params) do
    @db_domain_url <> "/api/profile"
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Show profile
  """
  def show(conn, params) do
    @db_domain_url <> "/api/profile"
    |> get_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
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

    @db_domain_url <> "/api/profile/update_icon"
    |> send_profile_multipart(params, file_path)
    ~> response

    unless params["image"] == "", do: File.rm(file_path)

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end
end
