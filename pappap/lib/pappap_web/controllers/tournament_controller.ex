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
  @match_start_url "/start"
  @delete_loser_url "/deleteloser"
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
  #FIXME: 長いのでリファクタリングが必要
  def create(conn, params) do
    file_path = unless params["image"] == "" do
      uuid = SecureRandom.uuid()
      File.cp(params["image"].path, "./static/image/tmp/#{uuid}.jpg")
      "./static/image/tmp/"<>uuid<>".jpg"
    else
      "./static/image/stones.png"
    end

    map =
      @db_domain_url <> @api_url <> @tournament_url
      |> send_tournament_multipart(params, file_path)

    Task.start_link(fn ->
      map["data"]["followers"]
      |> Enum.each(fn follower ->
        follower["id"]
        |> Accounts.get_devices_by_user_id()
        |> Enum.each(fn device ->
          Notifications.push(follower["name"]<>"さんが大会を予定しました。", device.device_id)
        end)
      end)
    end)
    Task.start_link(fn ->
      event_time =
        map["data"]["event_date"]
        |> Timex.parse!("{ISO:Extended}")
        |> DateTime.to_unix()

      now =
        DateTime.utc_now()
        |> DateTime.to_unix()
      IO.inspect(event_time - now, label: :left_second)
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
    end)

    unless params["image"] == "" do
      File.rm(file_path)
    end

    json(conn, map)
  end

  @doc """
  Starts a tournament.
  """
  def start(conn, params) do
    #log = Task.async(PappapWeb.TournamentController, :add_log, [params])
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @match_start_url
      |> send_json(params)
    #Task.await(log)

    json(conn, map)
  end

  defp add_log(params) do
    tournament_data =
      @db_domain_url <> @api_url <> @tournament_url <> @get_url
      |> send_json(params["tournament"])
    @db_domain_url <> @api_url <> @tournament_log_url <> @add_url
    |> send_json(tournament_data)
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
      # もともと非同期処理で書いていた
      map =
        @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
        |> send_json(%{"tournament" => %{"tournament_id" => tournament_id, "loser_list" => [params["opponent_id"]]}})

      PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})
      Logger.info("match_finihed notification has been sent.")

      updated_match_list = map["updated_match_list"]
      if is_integer(updated_match_list) do
        map =
          @db_domain_url <> @api_url <> @tournament_url <> @finish
          # FIXME: Using dummy user id.
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

      PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})
      Logger.info("match_finihed notification has been sent.")

      updated_match_list = map["updated_match_list"]
      if is_integer(updated_match_list) do
        map =
          @db_domain_url <> @api_url <> @tournament_url <> @finish
          # FIXME: Using dummy user id.
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

    if map["result"] do
      topic = "tournament:" <> to_string(params["tournament_id"])
      PappapWeb.Endpoint.broadcast(topic, "tournament_finished", %{msg: "tournament finished"})
    end

    json(conn, map)
  end

  # DEBUG:
  def debug_tournament_ws(conn, %{"tournament_id" => id}) do
    IO.inspect(conn, label: :conn)
    id = unless is_binary(id) do
      to_string(id)
    end

    PappapWeb.Endpoint.broadcast("tournament:"<>id, "DEBUG", %{msg: "debug notification"})
    PappapWeb.Endpoint.broadcast("tournament:"<>id, "tournament_finished", %{msg: "debug notification"})

    json(conn, %{msg: "done"})
  end
end
