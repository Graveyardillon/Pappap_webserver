defmodule PappapWeb.DeviceController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  alias Pappap.{
    Accounts,
    Notifications
  }

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"

  def pass_post_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/device/" <> path
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  # 通知送信DEBUG
  def force_notify(conn, params) do
    Notifications.push("強制通知が送信されました！", params["device_id"], 4)

    json(conn, %{msg: "sent notification"})
  end

  # WebSocket送信DEBUG
  def broadcast(conn, _params) do
    PappapWeb.Endpoint.broadcast("online", "force", %{msg: "done"})

    json(conn, %{msg: "broadcast done"})
  end
end
