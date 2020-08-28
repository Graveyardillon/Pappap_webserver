defmodule PappapWeb.ChatChannel do
  use Phoenix.Channel

  require Logger

  alias Pappap.Chat
  alias Pappap.Notifications
  alias Pappap.Accounts

  def join("chat:" <> _room_id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_chat", payload, socket) do
    with {:ok, _response} <- Chat.send_chat(payload) do
      # do nothing
    else
      {:error, _} -> Logger.error("Error on sending chat")
      _ -> Logger.error("Unexpected error on sending chat")
    end

    message = payload["chat"]["word"]
    partner_id = payload["chat"]["partner_id"]

    device = Accounts.get_device_by_user_id(partner_id) 
             |> hd()
    Notifications.push(message, device.device_id)

    #broadcast!(socket, "new_chat", %{payload: payload, response: response})
    broadcast!(socket, "new_chat", %{payload: payload})
    {:noreply, socket}
  end
end