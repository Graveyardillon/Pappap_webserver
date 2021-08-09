defmodule PappapWeb.DeviceController do
  use PappapWeb, :controller
  use Common.Tools

  alias Pappap.{
    Accounts,
    Notifications
  }

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"

  def pass_post_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/device/" <> path 
      |> send_json(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  # def register_device_id(conn, params \\ %{}) do
    # params["device_id"]
    # |> Accounts.from_device_id()
    # |> case do
    #   nil ->
    #     {:ok, device} =
    #       params
    #       |> Accounts.create_device()

    #     json(conn, %{device_id: device.device_id})
    #   device ->
    #     device
    #     |> Accounts.update_device(%{user_id: params["user_id"]})
    #     |> IO.inspect(label: :updation)
    #     json(conn, %{device_id: device.device_id})
    # end

  #   map = @db_domain_url <> "/api/register/device"
  #     |> send_json(params)

  #   case map do
  #     %{"result" => false, "reason" => _reason} ->
  #       conn
  #       |> put_status(500)
  #       |> json(map)
  #     map ->
  #       json(conn, map)
  #   end
  # end

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
