defmodule PappapWeb.PublicChatChannel do
  use Phoenix.Channel

  def join("public_chat:lobby", _msg, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end