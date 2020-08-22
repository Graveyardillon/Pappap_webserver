defmodule PappapWeb.ChatChannel do
  use Phoenix.Channel

  alias Pappap.Chat

  def join("chat:" <> _room_id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_chat", payload, socket) do
    response = Chat.send_chat(payload)

    broadcast!(socket, "new_chat", %{payload: payload, response: response})
    {:noreply, socket}
  end
end