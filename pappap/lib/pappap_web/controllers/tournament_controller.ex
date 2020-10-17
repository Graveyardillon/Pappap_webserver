defmodule PappapWeb.TournamentController do
  use PappapWeb, :controller
  use Common.Tools

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
  @content_type [{"Content-Type", "application/json"}]

  def get_participating_tournaments(conn, params) do
    map =
      @db_domain_url <> @api_url <> @get_participating_tournaments_url
      |>sendHTTP(params, @content_type)
      json(conn,map)
  end

  def get_tournament_topics(conn, params) do
    map =
      @db_domain_url <> @api_url <> @get_tournament_topics_url
      |>sendHTTP(params, @content_type)
      json(conn,map)
  end
  
  def start(conn, params) do
    log = Task.async(PappapWeb.TournamentController, :add_log, [params])
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @match_start_url
      |>sendHTTP(params, @content_type)
    Task.await(log)
    json(conn, map)
  end

  def add_log(params) do
    IO.inspect(params)
    tournament_data =
      @db_domain_url <> @api_url <> @tournament_url <> @get_url
      |>sendHTTP(params["tournament"], @content_type)
      |>IO.inspect(label: :add_log)
    @db_domain_url <> @api_url <> @tournament_log_url <> @add_url
    |>sendHTTP(tournament_data, @content_type)
  end

  def delete_loser(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
      |>sendHTTP(params, @content_type)
    json(conn, map)
  end
end