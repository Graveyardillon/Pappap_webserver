defmodule PappapWeb.TournamentController do
  use PappapWeb, :controller
  use Common.Tools
  use Timex
  alias Pappap.Notifications
  alias Pappap.Accounts

  require Logger

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
  @masters "/masters"
  @duplicate_users "/duplicate_claims"
  @finish "/finish"

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/tournament/" <> path
      |> get_parammed_request(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Pass a post request to database server.
  """
  def pass_post_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/tournament/" <> path
      |> send_json(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Creates a tournament.
  """
  def create(conn, params) do
    file_path = unless params["image"] == "" do
      uuid = SecureRandom.uuid()
      IO.inspect(params["image"].path, label: :path)
      File.cp(params["image"].path, "./static/image/tmp/#{uuid}.jpg")
      "./static/image/tmp/"<>uuid<>".jpg"
    else
      "./static/image/fire-free.jpg"
    end

    map =
      @db_domain_url <> @api_url <> @tournament_url
      |> send_tournament_multipart(params, file_path)

    Task.async(fn -> notify_followers_tournament_plans(map["data"]["followers"]) end)
    Task.async(fn -> notify_entrants_on_tournament_start(map) end)
    |> case do
      %Task{pid: pid} ->
        pid
        |> :erlang.pid_to_list()
        |> inspect()
        |> register_pid(map["data"]["id"])
    end

    unless params["image"] == "", do: File.rm(file_path)

    json(conn, map)
  end

  defp notify_followers_tournament_plans(followers) do
    followers
    |> Enum.each(fn follower ->
      follower["id"]
      |> Accounts.get_devices_by_user_id()
      |> Enum.each(fn device ->
        Notifications.push(follower["name"]<>"さんが大会を予定しました。", device.device_id, 5)
      end)
    end)
  end

  defp notify_entrants_on_tournament_start(map) do
    IO.inspect(map, label: :map)

    event_time =
      map["data"]["event_date"]
      |> IO.inspect(label: :event_date)
      |> Timex.parse!("{ISO:Extended}")
      |> DateTime.to_unix()

    now =
      DateTime.utc_now()
      |> DateTime.to_unix()

    Process.sleep((event_time - now)*1000)

    url = @db_domain_url <> @api_url <> @get_tournament_info_url
    content_type = [{"Content-Type", "application/json"}]

    p = Poison.encode!(%{"tournament_id" => map["data"]["id"]})

    HTTPoison.post(url, p, content_type)
    |> case do
      {:ok, response} ->
        res = Poison.decode!(response.body)

        res["data"]["entrants"]
        |> Enum.each(fn entrant ->
          entrant["id"]
          |> Accounts.get_devices_by_user_id()
          |> IO.inspect(label: :device)
          |> Enum.each(fn device ->
            Notifications.push(res["data"]["name"]<>"の開始時刻になりました。", device.device_id, 6)
          end)
        end)
      {:error, reason} ->
        IO.inspect(reason, label: :reason)
    end
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
    Logger.info(params["tournament"]["tournament_id"])
    tournament_id = params["tournament"]["tournament_id"]

    params["is_forced"]
    |> is_nil()
    |> unless do
      if params["is_forced"] == true || params["is_forced"] == "1" do
        cancel_notification(tournament_id)
      end
    end

    map =
      @db_domain_url <> @api_url <> @tournament_url <> @start_url
      |> send_json(params)

    if map["result"] do
      topic = "tournament:" <> to_string(tournament_id)
      PappapWeb.Endpoint.broadcast(topic, "tournament_started", %{msg: "tournament started", id: tournament_id})
      Logger.info("tournament_started notification has been sent.")
    end

    json(conn, map)
  end

  defp cancel_notification(tournament_id) do
    params = %{"tournament_id" => tournament_id}
    map =
      @db_domain_url <> @api_url <> @get_pid
      |> get_parammed_request(params)

    pid_str = map["pid"]
    {pid_charlist, _} = Code.eval_string(pid_str)
    pid = :erlang.list_to_pid(pid_charlist)

    Process.exit(pid, :kill)
    Logger.info("tournament notification " <> to_string(tournament_id) <> " is canceled")
  end

  @doc """
  Deletes losers.
  """
  def delete_loser(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
      |> send_json(params)

    json(conn, map)
  end

  @doc """
  Starts a match.
  """
  def start_match(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @start_match_url
      |> send_json(params)

    if map["result"] do
      topic = "tournament:" <> to_string(params["tournament_id"])
      PappapWeb.Endpoint.broadcast(topic, "match_started", %{msg: "match started"})
      Logger.info("match_started notification has been sent.")
    end

    json(conn, map)
  end

  @doc """
  Claims win.
  """
  def claim_win(conn, params) do
    tournament_id = params["tournament_id"]
    opponent_id = params["opponent_id"]
    user_id = params["user_id"]

    topic = "tournament:" <> to_string(tournament_id)

    map =
      @db_domain_url <> @api_url <> @tournament_url <> @claim_win
      |> send_json(params)

    unless map["validated"] do
      map =
        @db_domain_url <> @api_url <> @get_tournament_info_url
        |> get_parammed_request(%{"tournament_id" => tournament_id})

      push_notification_on_game_masters(tournament_id)
      PappapWeb.Endpoint.broadcast(topic, "duplicate_claim", %{tournament_id: tournament_id, opponent_id: opponent_id, user_id: user_id, master_id: map["data"]["master_id"]})
    end

    if map["completed"] do
      map =
        @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
        |> send_json(%{"tournament" => %{"tournament_id" => tournament_id, "loser_list" => [params["opponent_id"]]}})

      PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})
      Logger.info("match_finihed notification has been sent.")

      updated_match_list = map["updated_match_list"]
      if is_integer(updated_match_list) do
        map =
          @db_domain_url <> @api_url <> @tournament_url <> @finish
          # XXX: Using dummy user id.
          |> send_json(%{"tournament_id" => tournament_id, "user_id" => 0})

        if map["result"] do
          topic = "tournament:" <> to_string(params["tournament_id"])
          PappapWeb.Endpoint.broadcast(topic, "tournament_finished", %{msg: "tournament finished"})
          Logger.info("tournament_finished notification has been sent.")
        end
      end
    end

    json(conn, map)
  end

  @doc """
  Claims lose.
  """
  def claim_lose(conn, params) do
    tournament_id = params["tournament_id"]
    opponent_id = params["opponent_id"]
    user_id = params["user_id"]

    topic = "tournament:" <> to_string(tournament_id)

    map =
      @db_domain_url <> @api_url <> @tournament_url <> @claim_lose
      |> send_json(params)

    unless map["validated"] do
      map =
        @db_domain_url <> @api_url <> @get_tournament_info_url
        |> get_parammed_request(%{"tournament_id" => tournament_id})

      push_notification_on_game_masters(tournament_id)
      PappapWeb.Endpoint.broadcast(topic, "duplicate_claim", %{tournament_id: tournament_id, opponent_id: opponent_id, user_id: user_id, master_id: map["data"]["master_id"]})
    end

    if map["completed"] do
      map =
        @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
        |> send_json(%{"tournament" => %{"tournament_id" => params["tournament_id"], "loser_list" => [params["user_id"]]}})

      PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})
      Logger.info("match_finihed notification has been sent.")

      updated_match_list = map["updated_match_list"]
      if is_integer(updated_match_list) do
        map =
          @db_domain_url <> @api_url <> @tournament_url <> @finish
          # XXX: Using dummy user id.
          |> send_json(%{"tournament_id" => tournament_id, "user_id" => 0})

        if map["result"] do
          topic = "tournament:" <> to_string(params["tournament_id"])
          PappapWeb.Endpoint.broadcast(topic, "tournament_finished", %{msg: "tournament finished"})
          Logger.info("tournament_finished notification has been sent.")
        end
      end
    end

    json(conn, map)
  end

  defp push_notification_on_game_masters(tournament_id) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @masters
      |> get_parammed_request(%{"tournament_id" => tournament_id})

    if is_list(map["data"]) do
      map["data"]
      |> Enum.each(fn master ->
        master["id"]
        |> Accounts.get_devices_by_user_id()
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
    |> Map.get("data")
    |> Enum.reduce("", fn user, acc ->
      acc <> user["name"] <> " "
    end)
  end

  @doc """
  Finishes a tournament.
  """
  def finish(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @finish
      |> send_json(params)
    id = params["tournament_id"]

    if map["result"] do
      topic = "tournament:" <> to_string(id)
      PappapWeb.Endpoint.broadcast(topic, "tournament_finished", %{msg: "tournament finished", id: id})
    end

    json(conn, map)
  end

  # DEBUG:
  def debug_tournament_ws(conn, %{"tournament_id" => id}) do
    IO.inspect(conn, label: :conn)
    id = unless is_binary(id), do: to_string(id)

    PappapWeb.Endpoint.broadcast("tournament:"<>id, "DEBUG", %{msg: "debug notification"})
    PappapWeb.Endpoint.broadcast("tournament:"<>id, "tournament_started", %{msg: "debug notification", id: id})
    #PappapWeb.Endpoint.broadcast("tournament:"<>id, "tournament_finished", %{msg: "debug notification"})

    json(conn, %{msg: "done"})
  end
end
