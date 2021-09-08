defmodule PappapWeb.TournamentController do
  use PappapWeb, :controller
  use Common.Tools
  use Timex

  require Logger

  import Common.Sperm

  alias Pappap.{
    Accounts,
    Notifications
  }

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @tournament_url "/tournament"
  @get_tournament_info_url "/tournament/get"
  @start_url "/start"
  @start_match_url "/start_match"
  @delete_loser_url "/deleteloser"
  @register_url "/tournament/register/pid"
  @get_pid "/tournament/pid"
  @claim_win "/claim_win"
  @claim_lose "/claim_lose"
  @claim_score "/claim_score"
  @force_to_defeat "/defeat"
  @masters "/masters"
  @duplicate_users "/duplicate_claims"
  @report "/tournament_report"
  @finish "/finish"

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/tournament/" <> path
    |> get_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Pass a post request to database server.
  """
  def pass_post_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/tournament/" <> path
    |> send_json(params)
    ~> response

    if response.body["result"] do
      topic = "tournament:#{params["tournament_id"]}"

      case params["string"] do
        "ban_maps" ->
          IO.inspect("ban_maps: #{params["tournament_id"]}")
          PappapWeb.Endpoint.broadcast(topic, "banned_map", %{msg: "banned map", tournament_id: params["tournament_id"]})
        "choose_map" ->
          IO.inspect("choose_map: #{params["tournament_id"]}")
          PappapWeb.Endpoint.broadcast(topic, "chose_map", %{msg: "chose map", tournament_id: params["tournament_id"]})
        "choose_ad" ->
          IO.inspect("choose_ad: #{params["tournament_id"]}")
          PappapWeb.Endpoint.broadcast(topic, "chose_ad", %{msg: "chose ad", tournament_id: params["tournament_id"]})
        "flip_coin" ->
          IO.inspect("flip_coin: #{params["tournament_id"]}")
          PappapWeb.Endpoint.broadcast(topic, "flip_coin", %{msg: "flip_coin", tournament_id: params["tournament_id"]})
        _ ->
      end
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Pass a request of home to database server
  """
  def pass_home_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/tournament/home/" <> path
    |> get_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Creates a tournament.
  """
  def create(conn, params) do
    unless params["image"] == "" do
      uuid = SecureRandom.uuid()
      File.cp(params["image"].path, "./static/image/tmp/#{uuid}.jpg")
      "./static/image/tmp/"<>uuid<>".jpg"
    else
      "./static/image/default_BG.png"
    end
    ~> file_path

    @db_domain_url <> @api_url <> @tournament_url
    |> send_tournament_multipart(params, file_path)
    ~> response

    unless params["image"] == "", do: File.rm(file_path)

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  defp notify_followers_tournament_plans(followers) do
    # followers
    # |> Enum.each(fn follower ->
    #   follower["id"]
    #   |> Accounts.get_devices_by_user_id()
    #   |> Enum.each(fn device ->
    #     Notifications.push(follower["name"]<>"さんが大会を予定しました。", device.device_id, 5)
    #   end)
    # end)
  end

  defp notify_entrants_on_tournament_start(map) do
    # event_time =
    #   map["data"]["event_date"]
    #   |> IO.inspect(label: :event_date)
    #   |> Timex.parse!("{ISO:Extended}")
    #   |> DateTime.to_unix()

    # now =
    #   DateTime.utc_now()
    #   |> DateTime.to_unix()

    # Process.sleep((event_time - now)*1000)

    # url = @db_domain_url <> @api_url <> @get_tournament_info_url
    # content_type = [{"Content-Type", "application/json"}]

    # p = Poison.encode!(%{"tournament_id" => map["data"]["id"]})

    # HTTPoison.post(url, p, content_type)
    # |> case do
    #   {:ok, response} ->
    #     res = Poison.decode!(response.body)

    #     res["data"]["entrants"]
    #     |> Enum.each(fn entrant ->
    #       entrant["id"]
    #       |> Accounts.get_devices_by_user_id()
    #       |> IO.inspect(label: :device)
    #       |> Enum.each(fn device ->
    #         Notifications.push(res["data"]["name"]<>"の開始時刻になりました。", device.device_id, 6)
    #       end)
    #     end)
    #   {:error, reason} ->
    #     IO.inspect(reason, label: :reason)
    # end
  end

  defp register_pid(pid, tournament_id) do
    params = %{"pid" => pid, "tournament_id" => tournament_id}
    map =
      @db_domain_url <> @api_url <> @register_url
      |> send_json(params)

    if map["result"] do
      Logger.info("pid has been stored")
    end
  end

  @doc """
  Starts a tournament.
  """
  def start(conn, params) do
    tournament_id = params["tournament"]["tournament_id"]

    @db_domain_url <> @api_url <> @tournament_url <> @start_url
    |> send_json(params)
    ~> response

    if response.body["result"] do
      topic = "tournament:" <> to_string(tournament_id)
      PappapWeb.Endpoint.broadcast(topic, "tournament_started", %{msg: "tournament started", id: tournament_id})
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  defp cancel_notification(tournament_id) do
    params = %{"tournament_id" => tournament_id}
    map =
      @db_domain_url <> @api_url <> @get_pid
      |> get_parammed_request(params)

    unless is_nil(map["pid"]) do
      pid_str = map["pid"]
      {pid_charlist, _} = Code.eval_string(pid_str)
      pid = :erlang.list_to_pid(pid_charlist)

      Process.monitor(pid)
      Process.exit(pid, :kill)
    end

    Logger.info("tournament notification " <> to_string(tournament_id) <> " is canceled")
  end

  @doc """
  Deletes losers.
  """
  def delete_loser(conn, params) do
    @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Starts a match.
  """
  def start_match(conn, params) do
    @db_domain_url <> @api_url <> @tournament_url <> @start_match_url
    |> send_json(params)
    ~> response

    if response.body["result"] do
      topic = "tournament:" <> to_string(params["tournament_id"])
      PappapWeb.Endpoint.broadcast(topic, "match_started", %{msg: "match started"})
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Claims win.
  """
  def claim_win(conn, params) do
    tournament_id = params["tournament_id"]
    opponent_id = params["opponent_id"]
    user_id = params["user_id"]

    topic = "tournament:" <> to_string(tournament_id)

    @db_domain_url <> @api_url <> @tournament_url <> @claim_win
    |> send_json(params)
    ~> response

    unless response.body["validated"] do
      @db_domain_url <> @api_url <> @get_tournament_info_url
      |> get_parammed_request(%{"tournament_id" => tournament_id})
      ~> response

      push_notification_on_game_masters(tournament_id)
      PappapWeb.Endpoint.broadcast(topic, "duplicate_claim", %{tournament_id: tournament_id, opponent_id: opponent_id, user_id: user_id, master_id: response.body["data"]["master_id"]})
    end

    if response.body["completed"] do
      @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
      |> send_json(%{"tournament" => %{"tournament_id" => tournament_id, "loser_list" => [params["opponent_id"]]}})
      ~> response

      PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})

      updated_match_list = response.body["updated_match_list"]
      if is_integer(updated_match_list) do
        @db_domain_url <> @api_url <> @tournament_url <> @finish
        |> send_json(%{"tournament_id" => tournament_id, "user_id" => user_id})
        ~> response

        if response.body["result"] do
          topic = "tournament:" <> to_string(params["tournament_id"])
          PappapWeb.Endpoint.broadcast(topic, "tournament_finished", %{msg: "tournament finished"})
        end
      end
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Claims lose.
  """
  def claim_lose(conn, params) do
    tournament_id = params["tournament_id"]
    opponent_id = params["opponent_id"]
    user_id = params["user_id"]

    topic = "tournament:" <> to_string(tournament_id)

    @db_domain_url <> @api_url <> @tournament_url <> @claim_lose
    |> send_json(params)
    ~> response

    unless response.body["validated"] do
      @db_domain_url <> @api_url <> @get_tournament_info_url
      |> get_parammed_request(%{"tournament_id" => tournament_id})
      ~> response

      push_notification_on_game_masters(tournament_id)
      PappapWeb.Endpoint.broadcast(topic, "duplicate_claim", %{tournament_id: tournament_id, opponent_id: opponent_id, user_id: user_id, master_id: response.body["data"]["master_id"]})
    end

    if response.body["completed"] do
      @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
      |> send_json(%{"tournament" => %{"tournament_id" => params["tournament_id"], "loser_list" => [params["user_id"]]}})
      ~> response

      PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})

      updated_match_list = response.body["updated_match_list"]
      if is_integer(updated_match_list) do
        @db_domain_url <> @api_url <> @tournament_url <> @finish
        |> send_json(%{"tournament_id" => tournament_id, "user_id" => opponent_id})
        ~> response

        if response.body["result"] do
          topic = "tournament:" <> to_string(params["tournament_id"])
          PappapWeb.Endpoint.broadcast(topic, "tournament_finished", %{msg: "tournament finished"})
        end
      end
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Claims score.
  """
  def claim_score(conn, params) do
    tournament_id = params["tournament_id"]
    opponent_id = params["opponent_id"]
    user_id = params["user_id"]

    topic = "tournament:" <> to_string(tournament_id)

    @db_domain_url <> @api_url <> @tournament_url <> @claim_score
    |> send_json(params)
    ~> response

    unless response.body["validated"] do
      @db_domain_url <> @api_url <> @get_tournament_info_url
      |> get_parammed_request(%{"tournament_id" => tournament_id})
      ~> response

      push_notification_on_game_masters(tournament_id)
      PappapWeb.Endpoint.broadcast(topic, "duplicate_claim", %{tournament_id: tournament_id, opponent_id: opponent_id, user_id: user_id, master_id: response.body["data"]["master_id"]})
    end

    if response.body["completed"] do
      PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})

      if response.body["is_finished"] do
        topic = "tournament:" <> to_string(params["tournament_id"])
        PappapWeb.Endpoint.broadcast(topic, "tournament_finished", %{msg: "tournament finished"})
      end
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  defp push_notification_on_game_masters(tournament_id) do
    @db_domain_url <> @api_url <> @tournament_url <> @masters
    |> get_parammed_request(%{"tournament_id" => tournament_id})
    ~> response

    if is_list(response.body["data"]) do
      response.body["data"]
      |> IO.inspect()
      |> Enum.each(fn master ->
        master["id"]
        |> Accounts.get_devices_by_user_id()
        |> IO.inspect()
        |> Enum.each(fn device ->
          users_str = get_duplicate_users(tournament_id)
          Notifications.push("勝敗報告にズレが生じています！ : " <> users_str, device.device_id, 7)
        end)
      end)
    end
  end

  defp get_duplicate_users(tournament_id) do
    @db_domain_url <> @api_url <> @tournament_url <> @duplicate_users
    |> get_parammed_request(%{"tournament_id" => tournament_id})
    |> Map.get(:body)
    |> Map.get("data")
    ~> data

    unless is_nil(data) do
      Enum.reduce(data, "", fn user, acc ->
        acc <> user["name"] <> " "
      end)
    else
      ""
    end
  end

  @doc """
  Force to defeat a user.
  """
  def force_to_defeat(conn, params) do
    @db_domain_url <> @api_url <> @tournament_url <> @force_to_defeat
    |> send_json(params)
    ~> response

    if response.body["result"] do
      topic = "tournament:" <> to_string(params["tournament_id"])
      PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Finishes a tournament.
  """
  def finish(conn, params) do
    @db_domain_url <> @api_url <> @tournament_url <> @finish
    |> send_json(params)
    ~> response

    id = params["tournament_id"]

    if response.body["result"] do
      topic = "tournament:" <> to_string(id)
      PappapWeb.Endpoint.broadcast(topic, "tournament_finished", %{msg: "tournament finished", id: id})
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Report
  """
  def report(conn, params) do
    @db_domain_url <> @api_url <> @report
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  # DEBUG:
  def debug_tournament_ws(conn, %{"tournament_id" => id, "state" => state}) do
    IO.inspect(conn, label: :state_conn)
    id = unless is_binary(id), do: to_string(id)

    #PappapWeb.Endpoint.broadcast("tournament:"<>id, "DEBUG", %{msg: "debug notification"})
    PappapWeb.Endpoint.broadcast("tournament:"<>id, state, %{msg: state, id: id})

    json(conn, %{msg: "done"})
  end

  def debug_tournament_ws(conn, %{"tournament_id" => id}) do
    IO.inspect(conn, label: :conn)
    id = unless is_binary(id), do: to_string(id)

    PappapWeb.Endpoint.broadcast("tournament:"<>id, "DEBUG", %{msg: "debug notification"})
    PappapWeb.Endpoint.broadcast("tournament:"<>id, "tournament_started", %{msg: "debug notification", id: id})

    json(conn, %{msg: "done"})
  end

  def redirect_by_url(conn, params) do
    conn
    |> Map.get(:req_headers)
    |> Enum.filter(fn header ->
      header
      |> elem(0)
      |> Kernel.==("user-agent")
    end)
    |> hd()
    |> elem(1)
    |> IO.inspect()
    |> UAInspector.parse()
    |> IO.inspect()
    |> Map.get(:os)
    |> Map.get(:name)
    |> IO.inspect()
    ~> os_name

    path = params["url"]

    params = Map.put(params, "os_name", os_name)

    @db_domain_url <> "/api/tournament/url/#{path}"
    |> get_parammed_request(params)
    ~> response
    |> Map.get(:body)
    |> case do
      %{"result" => false} ->
        conn
        |> put_status(response.status_code)
        |> json(response.body)
      map ->
        IO.inspect(map)
        url = map["url"]
        redirect(conn, external: url)
    end
  end
end
