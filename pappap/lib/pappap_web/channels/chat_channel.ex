defmodule PappapWeb.ChatChannel do
  use Phoenix.Channel

  alias Pappap.Chat
  alias Pappap.Notifications
  alias Pappap.Accounts

  def join("chat:" <> _room_id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_chat", payload, socket) do
    response = Chat.send_chat(payload)
    message = payload["chat"]["word"]
    user_id = payload["chat"]["user_id"]

    device = Accounts.get_device_by_user_id(user_id)
    Notifications.push(message, device.device_id)

    broadcast!(socket, "new_chat", %{payload: payload, response: response})
    {:noreply, socket}
  end
end