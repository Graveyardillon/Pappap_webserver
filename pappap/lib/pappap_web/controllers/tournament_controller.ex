defmodule PappapWeb.TournamentController do
  use PappapWeb, :controller

  @db_domain_url "http://localhost:4000"
  @api_url "/api"
  @get_participating_tournaments_url "/tournament/get_participating_tournaments"
  @get_tournament_topics_url "/tournament/get_tabs"
  @content_type [{"Content-Type", "application/json"}]

  def get_participating_tournaments(conn, params) do
    url = @db_domain_url <> @api_url <> @get_participating_tournaments_url

    with {:ok, attrs} <- Poison.encode(params),
      {:ok, response} <- HTTPoison.post(url, attrs, @content_type),
      {:ok, body} <- Poison.decode(response.body) do
        json(conn, body)
      else
        {:error, reason} ->
          map = %{
            "result" => false,
            "reason" => reason
          }
          json(conn, map)
        
        _ ->
          map = %{
            "result" => false,
            "reason" => "Unexpected error"
          }
          json(conn, map)
    end
  end

  def get_tournament_topics(conn, params) do
    url = @db_domain_url <> @api_url <> @get_tournament_topics_url

    with {:ok, attrs} <- Poison.encode(params),
      {:ok, response} <- HTTPoison.post(url, attrs, @content_type),
      {:ok, body} <- Poison.decode(response.body) do
        json(conn, body)
      else
        {:error, reason} ->
          map = %{
            "result" => false,
            "reason" => reason
          }
          json(conn, map)
        
        _ ->
          map = %{
            "result" => false,
            "reason" => "Unexpected error"
          }
          json(conn, map)
    end
  end
end