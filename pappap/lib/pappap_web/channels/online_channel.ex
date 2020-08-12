defmodule PappapWeb.OnlineChannel do
  use Phoenix.Channel

  require Logger

  alias Pappap.Accounts

  def join("online", _payload, socket) do
    {:ok, socket}
  end

  def handle_in("online", payload, socket) do
    %{"sender" => sender} = payload

    case Accounts.get_user_by_user_id(sender) do
      [] ->
        Logger.info("Unknown user")
      user ->
        user
        |> hd()
        |> Accounts.update_user(%{is_online: true})
    end

    broadcast!(socket, "online", %{user: sender})
    {:noreply, socket}
  end

  def handle_in("offline", payload, socket) do
    %{"sender" => sender} = payload

    case Accounts.get_user_by_user_id(sender) do
      [] ->
        Logger.info("Unknown user")
      user ->
        user
        |> hd()
        |> Accounts.update_user(%{is_online: false})
    end

    broadcast!(socket, "offline", %{user: sender})
    {:noreply, socket}
  end
end