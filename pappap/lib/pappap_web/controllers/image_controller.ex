defmodule PappapWeb.ImageController do
  use PappapWeb, :controller

  def upload(conn, %{"image_b64" => image_b64}) do
    IO.inspect(image_b64)
    json(conn, %{message: "done"})
  end
end