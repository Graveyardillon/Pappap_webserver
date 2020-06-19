defmodule PappapWeb.PageController do
  use PappapWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
