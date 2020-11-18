defmodule PappapWeb.TournamentController do
  use PappapWeb, :controller
  use Common.Tools
  use Timex
  alias Pappap.Notifications
  alias Pappap.Accounts

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @tournament_url "/tournament"
  @tournament_log_url "/tournament_log"
  @get_participating_tournaments_url "/tournament/get_participating_tournaments"
  @get_tournament_topics_url "/tournament/get_tabs"
  @get_tournament_info_url "/tournament/get"
  @match_start_url "/start"
  @get_url "/get"
  @add_url "/add"
  @delete_loser_url "/deleteloser"
  @match_list "/get_match_list"
  @claim_win "/claim_win"
  @claim_lose "/claim_lose"
  @masters "/masters"

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
          Notifications.push(follower["name"]<>"さんが大会を予定しました。", device.device_id, 5)
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
              Notifications.push(res["data"]["name"]<>"がスタートしました！", device.device_id, 6)
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

  def get_participating(conn, params) do
    map =
      @db_domain_url <> @api_url <> @get_participating_tournaments_url
      |> send_json(params)

    json(conn, map)
  end

  def get_tournament_topics(conn, params) do
    map =
      @db_domain_url <> @api_url <> @get_tournament_topics_url
      |> send_json(params)

    json(conn, map)
  end
  
  def start(conn, params) do
    log = Task.async(PappapWeb.TournamentController, :add_log, [params])
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @match_start_url
      |> send_json(params)
    Task.await(log)

    json(conn, map)
  end

  def add_log(params) do
    tournament_data =
      @db_domain_url <> @api_url <> @tournament_url <> @get_url
      |> send_json(params["tournament"])
    @db_domain_url <> @api_url <> @tournament_log_url <> @add_url
    |> send_json(tournament_data)
  end

  def delete_loser(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
      |> send_json(params)

    json(conn, map)
  end

  def get_match_list(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @match_list
      |> send_json(params)
    
    json(conn, map)
  end

  def claim_win(conn, params) do
    map = 
      @db_domain_url <> @api_url <> @tournament_url <> @claim_win
      |> send_json(params)

    unless map["validated"] do
      Task.start_link(fn -> 
        notify_game_masters(params["tournament_id"])
      end)
    end

    if map["completed"] do
      Task.start_link(fn ->
        topic = "tournament:" <> to_string(params["tournament_id"])
        PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})
        
        @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
        |> send_json(%{"tournament" => %{"tournament_id" => params["tournament_id"], "loser_list" => [params["opponent_id"]]}})
      end)
    end

    json(conn, map)
  end

  def claim_lose(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @claim_lose
      |> send_json(params)

    unless map["validated"] do
      Task.start_link(fn -> 
        notify_game_masters(params["tournament_id"])
      end)
    end

    if map["completed"] do
      Task.start_link(fn -> 
        topic = "tournament:" <> to_string(params["tournament_id"])
        PappapWeb.Endpoint.broadcast(topic, "match_finished", %{msg: "match finished"})

        @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
        |> send_json(%{"tournament" => %{"tournament_id" => params["tournament_id"], "loser_list" => [params["user_id"]]}})
      end)
    end

    json(conn, map)
  end

  # XXX: 通知の動作確認まだ
  defp notify_game_masters(tournament_id) do
    map = 
      @db_domain_url <> @api_url <> @tournament_url <> @masters
      |> send_json(%{"tournament_id" => tournament_id})

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
end