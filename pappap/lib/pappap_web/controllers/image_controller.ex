defmodule PappapWeb.ImageController do
  use PappapWeb, :controller

  def upload(conn, %{"image_b64" => image_b64}) do
    if String.starts_with?(image_b64, "data:image/png;base64,") do
      "data:image/png;base64," <> raw = image_b64
      uuid = SecureRandom.uuid()
      File.write!("./static/image/#{uuid}.png", Base.decode64!(raw))

      json(conn, %{local_path: uuid})
    else
      raw = image_b64
      uuid = SecureRandom.uuid()
      File.write!("./static/image/#{uuid}.png", Base.decode64!(raw))

      json(conn, %{local_path: uuid})
    end
  end
end