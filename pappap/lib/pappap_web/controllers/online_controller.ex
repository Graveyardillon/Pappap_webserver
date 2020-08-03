defmodule PappapWeb.OnlineController do
  use PappapWeb, :controller

  def go_online(conn, %{"id" => id}) do
    json(conn, %{id: id})
  end
end