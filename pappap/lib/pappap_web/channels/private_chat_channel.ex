defmodule PappapWeb.PrivateChatChannel do
  use Phoenix.Channel

  alias Pappap.Chat

  def join("private_chat:" <> _private_room_id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    # %{"sender" => sender} = body
    # %{"partner" => partner} = body
    # %{"msg" => msg} = body
    Chat.send_chat(body)

    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end