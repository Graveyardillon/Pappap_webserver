defmodule PappapWeb.OnlineChannel do
  use Phoenix.Channel

  require Logger

  alias Pappap.Accounts

  def join("online:online", payload, socket) do
    %{"sender" => sender} = payload

    case Accounts.get_user_by_user_id(sender) do
      [] ->
        Logger.info("Unknown user to go online")
      user ->
        user
        |> hd()
        |> Accounts.update_user(%{is_online: true})
    end

    {:ok, socket}
  end

  def handle_in("offline", payload, socket) do
    %{"sender" => sender} = payload

    case Accounts.get_user_by_user_id(sender) do
      [] ->
        Logger.info("Unknown user to go offline")
      user ->
        user
        |> hd()
        |> Accounts.update_user(%{is_online: false})
    end

    {:noreply, socket}
  end
end