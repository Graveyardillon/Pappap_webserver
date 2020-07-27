defmodule PappapWeb.PrivateChatChannel do
  use Phoenix.Channel

  # This function is called when client connects to this server.
  def join("private_chat:lobby", _msg, socket) do
    {:ok, socket}
  end

  def join("private_chat:" <> _private_room_id, _auth_msg, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end