defmodule PappapWeb.ChatChannel do
  use Phoenix.Channel

  require Logger

  alias Pappap.Chat
  alias Pappap.Notifications
  alias Pappap.Accounts

  def join("chat:" <> _room_id, _payload, socket) do
    {:ok, socket}
  end

  #TODO: 関数に分割して可読性の向上
  def handle_in("new_chat", payload, socket) do
    payload
    |> Map.has_key?("chat")
    |> (if do
      with {:ok, _response} <- Chat.send_chat(payload) do
        message = payload["chat"]["word"]
        partner_id = payload["chat"]["partner_id"]

        Accounts.get_device_by_user_id(partner_id)
        |> notify(message)

        broadcast!(socket, "new_chat", %{payload: payload})
      else
        {:error, _} -> Logger.error("Error on sending chat")
        _ -> Logger.error("Unexpected error on sending chat")
      end

      {:noreply, socket}
    else
      # Map.has_key?/1 が chatじゃなかった場合（直接のメッセージという保証なし）
      with {:ok, response} <- Chat.send_chat(payload) do
        message = payload["chat_group"]["word"]
        members = response["members"]

        members
        |> is_list()
        |> (if do
          members
          |> Enum.each(fn member_id ->
            Accounts.get_device_by_user_id(member_id)
            |> notify(message)
          end)
        end)

        broadcast!(socket, "new_chat", %{payload: payload})
      else
        {:error, _} -> Logger.error("Error on sending group chat")
        _ -> Logger.error("Unexpected error on sending chat")
      end
      
      {:noreply, socket}
    end)
  end

  defp notify(device_list, message) do
    device_list
    |> Enum.empty?()
    |> (unless  do
      device = hd(device_list)
      Notifications.push(message, device.device_id)
    end)
  end
end