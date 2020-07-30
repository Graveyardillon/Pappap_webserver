defmodule PappapWeb.ImageController do
  use PappapWeb, :controller

  def upload(conn, %{"image_b64" => image_b64}) do
    "data:image/png;base64," <> raw = image_b64
    File.write!("./static/image/a.png", Base.decode64!(raw))

    json(conn, %{message: "done"})
  end
end