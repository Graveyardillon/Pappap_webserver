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

    #device = Accounts.get_device_by_user_id(user_id)
    Notifications.push(message, "c20daadeda3329ad256b6e2fd306b9fbb9f1053e575e24d3d70b50793c8e2fa2")

    broadcast!(socket, "new_chat", %{payload: payload, response: response})
    {:noreply, socket}
  end
end