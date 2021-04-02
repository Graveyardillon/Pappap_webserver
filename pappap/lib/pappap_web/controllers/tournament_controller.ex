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
  @finish "/finish"
  @get_url "/get"
  @add_url "/add"
  @tournament_log_url "/tournament_log"

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
      File.cp(params["image"].path, "./static/image/tmp/#{uuid}.jpg")
      "./static/image/tmp/"<>uuid<>".jpg"
    else
      # FIXME: temporary picture
      "./static/image/stones.png"
    end

    map =
      @db_domain_url <> @api_url <> @tournament_url
      |> send_tournament_multipart(params, file_path)

    Task.start_link(fn -> notify_followers_tournament_plans(map["data"]["followers"]) end)
    Task.start_link(fn -> notify_entrants_on_tournament_start(map) end)
    |> case do
      {:ok, pid} ->
        pid_str = pid
          |> :erlang.pid_to_list()
          |> inspect()
        register_pid(pid_str, map["data"]["id"])
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
        Notifications.push(follower["name"]<>"さんが大会を予定しました。", device.device_id)
      end)
    end)
  end

  defp notify_entrants_on_tournament_start(map) do
    event_time =
      map["data"]["event_date"]
      |> Timex.parse!("{ISO:Extended}")
      |> DateTime.to_unix()

    now =
      DateTime.utc_now()
      |> DateTime.to_unix()
    #IO.inspect(event_time - now, label: :left_second)

    Process.sleep((event_time - now)*1000)

    url = @db_domain_url <> @api_url <> @get_tournament_info_url
    content_type = [{"Content-Type", "application/json"}]

    p = Poison.encode!(%{"tournament_id" => map["data"]["id"]})

    case HTTPoison.post(url, p, content_type) do
      {:ok, response} ->
        res = Poison.decode!(response.body)

        res["data"]["entrants"]
        |> Enum.each(fn entrant ->
          entrant["id"]
          |> Accounts.get_devices_by_user_id()
          |> Enum.each(fn device ->
            Notifications.push(res["data"]["name"]<>"がスタートしました！", device.device_id)
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
    tournament_id = params["tournament"]["tournament_id"]

    params["is_forced"]
    |> is_nil()
    |> unless do
      # nilじゃなければ
      if params["is_forced"] do
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

  defp add_log(params) do
    tournament_data =
      @db_domain_url <> @api_url <> @tournament_url <> @get_url
      |> send_json(params["tournament"])
    @db_domain_url <> @api_url <> @tournament_log_url <> @add_url
    |> send_json(tournament_data)
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
      # FIXME: 通知を個人で行う必要がある
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
      notify_game_masters(tournament_id)
      PappapWeb.Endpoint.broadcast(topic, "invalid_claim", %{tournament_id: tournament_id, opponent_id: opponent_id, user_id: user_id})
    end

    if map["completed"] do
      # TODO: もともと非同期処理で書いていた
      map =
        @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
        |> send_json(%{"tournament" => %{"tournament_id" => tournament_id, "loser_list" => [params["opponent_id"]]}})

      # FIXME: match_finishedの通知を個人で行う必要がある
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
      notify_game_masters(tournament_id)
      PappapWeb.Endpoint.broadcast(topic, "invalid_claim", %{tournament_id: tournament_id, opponent_id: opponent_id, user_id: user_id})
    end

    if map["completed"] do
      # もともと非同期処理で書いていた
      map =
        @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
        |> send_json(%{"tournament" => %{"tournament_id" => params["tournament_id"], "loser_list" => [params["user_id"]]}})

      # FIXME: match_finishedの通知を個人で行う必要がある
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

  # FIXME: 通知の動作確認まだ
  defp notify_game_masters(tournament_id) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @masters <> "?tournament_id=" <> to_string(tournament_id)
      |> get_request()

    if is_list(map["data"]) do
      map["data"]
      |> Enum.each(fn master ->
        master["id"]
        |> Accounts.get_devices_by_user_id()
        |> Enum.each(fn device ->
          Notifications.push("勝敗報告にズレが生じています！", device.device_id, -1)
        end)
      end)
    end
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
