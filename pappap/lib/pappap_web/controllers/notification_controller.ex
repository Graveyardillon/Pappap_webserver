defmodule PappapWeb.NotificationController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @index_url "/notif/get_list"

  def index(conn, %{"user_id" => id}) do
    map =
      @db_domain_url <> @api_url <> @index_url
      |> send_json(%{"notif" => %{"user_id" => id}})

    json(conn, map)
  end
end