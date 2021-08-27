defmodule PappapWeb.DeviceControllerTest do
  use PappapWeb.ConnCase

  describe "register device id" do
    test "resister_device_id works fine", %{conn: conn} do
      conn = post(conn, Routes.device_path(conn, :register_device_id), %{"user_id" => 1, "device_id" => "1"})
      assert json_response(conn, 200)["device_id"] == "1"
    end

    test "register_device_id works with multiple insertion", %{conn: conn} do
      conn = post(conn, Routes.device_path(conn, :register_device_id), %{"user_id" => 1, "device_id" => "1"})
      conn = post(conn, Routes.device_path(conn, :register_device_id), %{"user_id" => 1, "device_id" => "1"})
      assert json_response(conn, 200)["device_id"] == "1"
    end
  end
end