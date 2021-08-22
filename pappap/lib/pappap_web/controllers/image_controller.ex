defmodule PappapWeb.ImageController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  #alias Common.FileUtils

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @upload_url "/chat/upload/image"
  @load_url "/chat/load/image"

  def upload(conn, params) do
    IO.inspect(params, label: :params)

    @db_domain_url <> @api_url <> @upload_url
    |> send_chat_image_multipart(params, params["image"].path)
    ~> map

    json(conn, map)
  end

  def load(conn, params) do
    @db_domain_url <> @api_url <> @load_url
    |> get_parammed_request(params)
    ~> map

    json(conn, map)
  end
end
