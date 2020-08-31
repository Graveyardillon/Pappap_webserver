defmodule PappapWeb.ImageView do
  use PappapWeb, :view

  def render("upload.json", %{local_path: uuid}) do
    %{local_path: uuid}
  end

  def render("load.json", %{b64: b64}) do
    %{b64: b64}
  end
end