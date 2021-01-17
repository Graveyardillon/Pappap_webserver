defmodule PappapWeb.DeviceController do
  use PappapWeb, :controller

  alias Pappap.Accounts
  alias Pappap.Notifications

  def register_device_id(conn, params) do
    {:ok, device} = params
      |> Accounts.create_device()

    json(conn, %{device_id: device.device_id})
  end

  # 通知送信
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
