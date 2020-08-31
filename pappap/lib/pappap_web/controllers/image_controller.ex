defmodule PappapWeb.ImageController do
  use PappapWeb, :controller

  def upload(conn, %{"image_b64" => image_b64}) do
    if String.starts_with?(image_b64, "data:image/png;base64,") do
      "data:image/png;base64," <> raw = image_b64
      uuid = SecureRandom.uuid()
      File.write!("./static/image/#{uuid}.png", Base.decode64!(raw))

      render(conn, %{local_path: uuid})
    else
      raw = image_b64
      uuid = SecureRandom.uuid()
      File.write!("./static/image/#{uuid}.png", Base.decode64!(raw))

      render(conn, %{local_path: uuid})
    end
  end

  def load(conn, %{"path" => path}) do
    b64 = File.read!("./static/image/#{path}.png")
          |> Base.encode64()

    render(conn, %{b64: b64})
  end
end