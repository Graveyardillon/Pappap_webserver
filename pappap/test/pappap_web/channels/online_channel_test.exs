defmodule PappapWeb.OnlineChannelTest do
  use PappapWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      PappapWeb.UserSocket
      |> socket("user_id", %{user_id: 2})
      |> subscribe_and_join(PappapWeb.OnlineChannel, "room:lobby", %{"user_id" => 2})

    %{socket: socket}
  end
end
