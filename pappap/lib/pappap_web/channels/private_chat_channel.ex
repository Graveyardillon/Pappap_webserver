defmodule PappapWeb.PrivateChatChannel do
  use Phoenix.Channel

  def join("private_chat:" <> _private_room_id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end