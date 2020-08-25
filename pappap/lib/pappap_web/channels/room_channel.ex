defmodule PappapWeb.RoomChannel do
  use PappapWeb, :channel
  alias PappapWeb.Presence

  def join("room:lobby", %{"user_id" => user_id}, socket) do
    send(self(), {:after_join, user_id})
    {:ok, socket}
  end

  def handle_info({:after_join, user_id}, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      user_id: user_id,
      online_at: inspect(System.system_time(:second))
    })
    # IO.inspect(Presence.list(socket))
    # push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  intercept ["presence_diff"]
  def handle_out("presence_diff", _, socket) do
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end