defmodule PappapWeb.DeviceController do
  use PappapWeb, :controller

  alias Pappap.Accounts

  def register_device_id(conn, params) do
    {:ok, device} = params
                    |> Accounts.create_device()

    json(conn, %{device_id: device.device_id})
  end
end