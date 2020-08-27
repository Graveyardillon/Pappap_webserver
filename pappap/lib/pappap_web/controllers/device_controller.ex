defmodule PappapWeb.DeviceController do
  use PappapWeb, :controller

  alias Pappap.Accounts

  def register_device_id(conn, params) do
    params
    |> Accounts.create_device()

    json(conn, %{message: "completed!"})
  end
end