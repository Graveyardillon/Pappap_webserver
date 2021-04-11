defmodule PappapWeb.DeviceController do
  use PappapWeb, :controller

  alias Pappap.{
    Accounts,
    Notifications
  }
  alias Pappap.Accounts.Device

  def register_device_id(conn, params \\ %{}) do
    params["device_id"]
    |> Accounts.from_device_id()
    |> case do
      nil ->
        {:ok, device} =
          params
          |> Accounts.create_device()

        json(conn, %{device_id: device.device_id})
      device ->
        device
        |> Accounts.update_device(%{user_id: params["user_id"]})
        |> IO.inspect(label: :updation)
        json(conn, %{device_id: device.device_id})
    end
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
