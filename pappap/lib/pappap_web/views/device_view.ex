defmodule PappapWeb.DeviceView do
  use PappapWeb, :view

  def render("legister_device_id.json", %{device_id: device_id}) do
    %{device_id: device_id}
  end

end