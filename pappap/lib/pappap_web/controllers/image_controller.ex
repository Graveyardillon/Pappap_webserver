defmodule PappapWeb.ImageController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  #alias Common.FileUtils

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @upload_url "/chat/upload/image"
  @load_url "/chat/load/image"

  def upload(conn, params = %{"image" => _image_b64}) do
    @db_domain_url <> @api_url <> @upload_url
    |> send_json(params)
    ~> map

    json(conn, map)
  end

  def load(conn, params = %{"path" => _path}) do
    # File.read!("./static/image/#{path}.png")
    # |> Base.encode64()
    # ~> b64

    @db_domain_url <> @api_url <> @load_url
    |> get_parammed_request(params)
    ~> map

    json(conn, map)
  end
end
