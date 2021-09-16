defmodule PappapWeb.ImageController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  #alias Common.FileUtils

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @upload_url "/chat/upload/image"
  @load_url "/chat/load/image"
  @image_thumbnail "/image/thumbnail"
  @image_icon "/image/icon"

  def upload(conn, params) do
    IO.inspect(params, label: :params)

    @db_domain_url <> @api_url <> @upload_url
    |> send_chat_image_multipart(params, params["image"].path)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  def load(conn, params) do
    @db_domain_url <> @api_url <> @load_url
    |> get_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  def pass_get_image_icon_request(conn, params) do
    @db_domain_url <> @api_url <> @image_icon
    |> get_image_request(params)
    ~> response
    |> case do
      {:ok, response} ->
        Enum.map(response.headers, fn header -> 
          if elem(header, 0) == "content-type", do: elem(header, 1)
        end)
        |> Enum.filter(& !is_nil(&1))
        |> List.first()
        ~> content_type

        if content_type == "image/jpeg" do
          conn
          |> put_status(response.status_code)
          |> put_resp_content_type("image/jpeg", nil)
          |> send_resp(200, response.body)
        else
          conn
          |> put_status(response.status_code)
          |> json(response.body)
        end
    _ ->
      json(conn, response)
    end
  end

  def pass_get_image_thumbnail_request(conn, params) do
    @db_domain_url <> @api_url <> @image_thumbnail
    |> get_image_request(params)
    ~> response
    |> case do
      {:ok, response} ->
        Enum.map(response.headers, fn header -> 
          if elem(header, 0) == "content-type", do: elem(header, 1)
        end)
        |> Enum.filter(& !is_nil(&1))
        |> List.first()
        ~> content_type

        if content_type == "image/jpeg" do
          conn
          |> put_status(response.status_code)
          |> put_resp_content_type("image/jpeg", nil)
          |> send_resp(200, response.body)
        else
          conn
          |> put_status(response.status_code)
          |> json(response.body)
        end
    _ ->
      json(conn, response)
    end
  end
  

end
