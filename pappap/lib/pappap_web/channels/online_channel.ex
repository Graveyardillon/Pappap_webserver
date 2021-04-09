defmodule PappapWeb.OnlineChannel do
  use PappapWeb, :channel
  use Common.Tools

  alias PappapWeb.Presence
  alias Pappap.Online
  alias Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @relevant "/tournament/relevant"
  @entrants "/tournament/get_entrants"

  def join("online", %{"user_id" => user_id}, socket) do
    user_id = Tools.to_integer_as_needed(user_id)
    {:ok, _} = Presence.track(socket, "#{inspect socket.transport_pid}", %{
      user_id: user_id,
      online_at: inspect(System.system_time(:second))
    })
    |> IO.inspect(label: :online_detect)
    Online.join(user_id)

    {:ok, socket}
  end

  def handle_info({:after_join, user_id}, socket) do
    {:ok, _} = Presence.track(socket, socket.assigns.user_id, %{
      user_id: user_id,
      online_at: inspect(System.system_time(:second))
    })

    {:noreply, socket}
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

  # FIXME: リファクタリングします
  intercept ["presence_diff"]
  def handle_out("presence_diff", %{joins: joins, leaves: leaves}, socket) do
    # IO.inspect(joins, label: :joins)
    # IO.inspect(leaves, label: :leaves)

    if !Enum.empty?(joins) do
      joins
      |> Map.values()
      |> Enum.each(fn %{metas: metas} ->
        metas
        |> Enum.each(fn meta ->
          notify_online_on_tournament_channel(meta.user_id)
        end)
      end)
    end

    if !Enum.empty?(leaves) do
      leaves
      |> Map.values()
      |> Enum.each(fn %{metas: metas} ->
        metas
        |> Enum.each(fn meta ->
          Online.leave(meta.user_id)
          notify_online_on_tournament_channel(meta.user_id)
        end)
      end)
    end

    # IO.inspect "#{inspect socket.channel_pid}"
    {:noreply, socket}
  end

  defp notify_online_on_tournament_channel(user_id) do
    params = %{"user_id" => user_id}

    @db_domain_url <> @api_url <> @relevant
    |> get_parammed_request(params)
    |> case do
      %{"result" => false, "reason" => _} -> []
      map -> map["data"]
    end
    |> Enum.each(fn tournament ->
      online_user_id_list =
        Online.list_online_users()
        |> Enum.map(fn ouser -> ouser.user_id end)
      entrant_num =
        tournament["id"]
        |> get_entrants()
        |> Enum.filter(fn entrant ->
          Enum.member?(online_user_id_list, entrant["user_id"])
        end)
        |> length()
      topic = "tournament:" <> to_string(tournament["id"])
      PappapWeb.Endpoint.broadcast(topic, "online_num_change", %{user_id: user_id, msg: "online_increment", entrant_num: entrant_num})
    end)
  end

  defp get_entrants(tournament_id) do
    params = %{"tournament_id" => tournament_id}
    @db_domain_url <> @api_url <> @entrants
    |> get_parammed_request(params)
    |> case do
      %{"result" => false, "reason" => _} -> []
      map -> map["data"]
    end
  end

  def broadcast_all(event, payload) do
    PappapWeb.Endpoint.broadcast("online", event, payload)
  end
end
