defmodule PappapWeb.ChatChannel do
  use Phoenix.Channel

  require Logger

  alias Pappap.Chat

  def join("chat:" <> _room_id, _payload, socket) do
    {:ok, socket}
  end

  def handle_in("new_chat", payload, socket) do
    payload
    |> Map.has_key?("chat")
    |> if do
      with {:ok, _response} <- Chat.send_chat(payload) do
        broadcast!(socket, "new_chat", %{payload: payload})
      else
        {:error, _} -> Logger.error("Error on sending chat")
        _ -> Logger.error("Unexpected error on sending chat")
      end

      {:noreply, socket}
    else
      # Map.has_key?/1 が chatじゃなかった場合（直接のメッセージという保証なし）
      with {:ok, _} <- Chat.send_chat(payload) do
        broadcast!(socket, "new_chat", %{payload: payload})
      else
        {:error, _} -> Logger.error("Error on sending group chat")
        _ -> Logger.error("Unexpected error on sending chat")
      end

      {:noreply, socket}
    end
  end
end
