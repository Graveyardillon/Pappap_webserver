defmodule PappapWeb.TournamentController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url "http://localhost:4000"
  @api_url "/api"
  @tournament_url "/tournament"
  @get_participating_tournaments_url "/tournament/get_participating_tournaments"
  @get_tournament_topics_url "/tournament/get_tabs"
  @match_start_url "/start"
  @delete_loser_url "/deleteloser"
  @content_type [{"Content-Type", "application/json"}]

  def get_participating_tournaments(conn, params) do
    map =
      @db_domain_url <> @api_url <> @get_participating_tournaments_url
      |>sendHTTP(params)
      json(conn,map)
  end

  def get_tournament_topics(conn, params) do
    map =
      @db_domain_url <> @api_url <> @get_tournament_topics_url
      |>sendHTTP(params)
      json(conn,map)
  end
  def start(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @match_start_url
      |>sendHTTP(params)
      json(conn, map)
    end
  end
  def delete_loser(conn, params) do
    map =
      @db_domain_url <> @api_url <> @tournament_url <> @delete_loser_url
      |>sendHTTP(params)
    json(conn, map)
  end
end