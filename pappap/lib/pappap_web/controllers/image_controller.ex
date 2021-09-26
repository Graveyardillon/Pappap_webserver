defmodule PappapWeb.ImageController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  #alias Common.FileUtils

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @upload_url "/chat/upload/image"
  @load_url "/chat/load/image"
  @image_by_path "/image/path"

  def upload(conn, params) do
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

  def pass_get_image_by_path_request(conn, params) do
    @db_domain_url <> @api_url <> @image_by_path
    |> get_image_request(params)
    ~> response
    |> case do
      {:ok, response} ->
        response
        |> Map.get(:headers)
        |> IO.inspect(label: :image_headers)
        |> Enum.map(fn header ->
          if elem(header, 0) == "Content-Type" || elem(header, 0) == "content-type" do
            elem(header, 1)
          end
        end)
        |> Enum.filter(& !is_nil(&1))
        |> List.first()
        |> IO.inspect(label: :image_type)
        |> case do
          "image/jpg" ->
            conn
            |> put_status(response.status_code)
            |> put_resp_content_type("image/jpg")
            |> send_resp(200, response.body)
          "image/jpg; charset=utf-8" ->
            conn
            |> put_status(response.status_code)
            |> put_resp_content_type("image/jpg")
            |> send_resp(200, response.body)
          "image/png" ->
            conn
            |> put_status(response.status_code)
            |> put_resp_content_type("image/png")
            |> send_resp(200, response.body)
          "image/png; charset=utf-8" ->
            conn
            |> put_status(response.status_code)
            |> put_resp_content_type("image/png")
            |> send_resp(200, response.body)
          _ ->
            conn
            |> put_status(response.status_code)
            |> json(response.body)
        end
    _ ->
      json(conn, response)
    end
  end

end
