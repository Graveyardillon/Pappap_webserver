defmodule PappapWeb.BrowserController do
  use PappapWeb, :controller

  def index(conn, _params) do
    json(conn, %{msg: "worked"})
  end
end
