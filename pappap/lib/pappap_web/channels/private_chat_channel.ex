defmodule PappapWeb.PrivateChatChannel do
  use Phoenix.Channel

  alias Pappap.Accounts

  def join("private_chat:" <> _private_room_id, payload, socket) do
    id = payload["sender"]

    Accounts.get_user_by_user_id(id)
    |> hd()
    |> Accounts.update_user(%{is_online: true})
    
    {:ok, socket}
  end

  def handle_in("new_msg", %{"body" => body}, socket) do
    broadcast!(socket, "new_msg", %{body: body})
    {:noreply, socket}
  end
end