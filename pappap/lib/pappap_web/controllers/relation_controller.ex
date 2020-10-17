defmodule PappapWeb.RelationController do
  use PappapWeb, :controller

  @db_domain_url "http://localhost:4000"
  @api_url "/api"
  @follow_url "/relation"
  @unfollow_url "/relation/unfollow"
  @list_url "/relation/following_list"
  @content_type [{"Content-Type", "application/json"}]

  def follow(conn, params) do
    url = @db_domain_url <> @api_url <> @follow_url

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

  def unfollow(conn, params) do
    url = @db_domain_url <> @api_url <> @unfollow_url

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

  def following_list(conn, params) do
    url = @db_domain_url <> @api_url <> @list_url

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