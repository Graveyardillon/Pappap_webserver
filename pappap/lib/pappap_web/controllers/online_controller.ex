defmodule PappapWeb.OnlineController do
  use PappapWeb, :controller
  use Common.Tools

  alias PappapWeb.Presence
  alias Pappap.Online

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @entrants "/tournament/get_entrants"

  def get_online_users(conn, _params) do
    users = Presence.list("online")

    json(conn, %{data: users})
  end

  def get_online_entrants(conn, %{"tournament_id" => tournament_id}) do
    params = %{"tournament_id" => tournament_id}
    online_user_id_list =
      Online.list_online_users()
      |> Enum.map(fn ouser -> ouser.user_id end)

    entrant_num =
      @db_domain_url <> @api_url <> @entrants
      |> get_parammed_request(params)
      |> case do
        %{"result" => false, "reason" => _} -> []
        map -> map["data"]
      end
      |> Enum.filter(fn entrant ->
        Enum.member?(online_user_id_list, entrant["user_id"])
      end)
      |> length()

    json(conn, %{online_num: entrant_num, result: true})
  end
end
