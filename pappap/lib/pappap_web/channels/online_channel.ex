defmodule PappapWeb.OnlineChannel do
  use PappapWeb, :channel
  alias PappapWeb.Presence

  def join("online", %{"user_id" => user_id}, socket) do
    # send(self(), {:after_join, user_id})
    IO.inspect socket
    {:ok, _} = Presence.track(socket, "online", %{
      user_id: user_id,
      online_at: inspect(System.system_time(:second))
    })
    Presence.track(socket, socket.channel_pid, %{user_id: user_id})
    {:ok, socket}
  end

  def handle_info({:after_join, user_id}, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      user_id: user_id,
      online_at: inspect(System.system_time(:second))
    })
    # IO.inspect(Presence.list(socket))
    # push(socket, "presence_state", Presence.list(socket))
    # {:noreply, socket}
  end

  def handle_in("get_online", params, socket) do
    IO.inspect socket
    %{"online"=>%{metas: metas}} = Presence.list(socket) |> IO.inspect
    list = Enum.map(metas, fn m -> m.user_id end)
    push(socket,"get_online",%{online: list})
    {:noreply, socket}
  end

  intercept ["presence_diff"]
  def handle_out("presence_diff", param, socket) do
    # IO.inspect param
    IO.inspect Presence.get_by_key("online",socket.channel_pid)
    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end