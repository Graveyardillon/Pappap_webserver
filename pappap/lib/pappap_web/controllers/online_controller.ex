defmodule PappapWeb.OnlineController do
  use PappapWeb, :controller
  
  alias PappapWeb.Presence

  def get_online_users(conn, _params) do
    users = Presence.list("online")

    json(conn, %{data: users})
  end
end