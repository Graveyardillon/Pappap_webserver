defmodule PappapWeb.OnlineChannel do
  use PappapWeb, :channel
  alias PappapWeb.Presence

  def join("online", %{"user_id" => user_id, "chat_room" => chat_room}, socket) do
    # send(self(), {:after_join, user_id})
    #IO.inspect Presence.list(socket)
    {:ok, _} = Presence.track(socket, "#{inspect socket.transport_pid}", %{
      chat_room: chat_room,
      user_id: user_id,
      online_at: inspect(System.system_time(:second))
    })
    # Presence.track(socket, socket.channel_pid, %{user_id: user_id})
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

  def handle_in("get_online", _params, socket) do
    # %{"online"=>%{metas: metas}} = Presence.list(socket)
    # list = Enum.map(metas, fn m -> m.user_id end)
    list = Enum.map(Presence.list(socket), fn {_k,v} ->
      hd(v.metas).user_id
    end)
    push(socket,"get_online",%{online: list})
    {:noreply, socket}
  end

  intercept ["presence_diff"]
  def handle_out("presence_diff", %{joins: joins, leaves: leaves}, socket) do
    chat_room = Presence.get_by_key("online", "#{inspect socket.transport_pid}")
      |> Map.get(:metas)
      |> hd
      |> Map.get(:chat_room)

    if !Enum.empty?(joins) do
      map = Map.values(joins)
        |> Enum.map(fn %{metas: metas} ->
          x = metas
            |> hd
          Enum.any?(x.chat_room, fn a -> Enum.member?(chat_room, a) end)
          |> if do
            x.user_id
          else
            nil
          end
        end)
        |> Enum.filter(fn x -> !is_nil(x) end)
      if !Enum.empty?(map) do
        push(socket, "online", %{online: map})
      end
    end

    if !Enum.empty?(leaves) do
      map = Map.values(leaves)
        |> Enum.map(fn %{metas: metas} ->
          x = metas
            |> hd
          Enum.any?(x.chat_room, fn a -> Enum.member?(chat_room, a) end)
          |> if do
            x.user_id
          else
            nil
          end
        end)
        |> Enum.filter(fn x -> !is_nil(x) end)
      if !Enum.empty?(map) do
        push(socket, "offline", %{offline: map})
      end
    end

    # IO.inspect "#{inspect socket.channel_pid}"
    {:noreply, socket}
  end
  def broadcast_all(event, payload) do
    PappapWeb.Endpoint.broadcast("online", event, payload)
  end
end
