defmodule PappapWeb.TournamentController do
  use PappapWeb, :controller
  use Common.Tools
  use Timex
  alias Pappap.Notifications
  alias Pappap.Accounts

  @db_domain_url "http://localhost:4000"
  @api_url "/api"
  @tournament_url "/tournament"
  @tournament_log_url "/tournament_log"
  @get_participating_tournaments_url "/tournament/get_participating_tournaments"
  @get_tournament_topics_url "/tournament/get_tabs"
  @match_start_url "/start"
  @get_url "/get"
  @add_url "/add"
  @delete_loser_url "/deleteloser"

  def create(conn, params) do
    IO.inspect(params, label: :create_params)
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
      |> IO.inspect()

    Task.async(fn -> 
      map["data"]["followers"]
      |> Enum.each(fn follower -> 
        follower["id"]
        |> Accounts.get_devices_by_user_id()
        |> Enum.each(fn device -> 
          Notifications.push(follower["name"]<>"さんが大会を予定しました。", device.device_id)
        end)
      end)
    end)

    IO.inspect(map["data"]["event_date"])
    
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
    IO.inspect(params)
    tournament_data =
      @db_domain_url <> @api_url <> @tournament_url <> @get_url
      |> send_json(params["tournament"])
      |> IO.inspect(label: :add_log)
    @db_domain_url <> @api_url <> @tournament_log_url <> @add_url
    |> send_json(tournament_data)
  end

  def delete_loser(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
      |> send_json(params)

    json(conn, map)
  end
end