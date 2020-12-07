defmodule PappapWeb.RelationController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @follow_url "/relation"
  @unfollow_url "/relation/unfollow"
  @list_url "/relation/following_list"
  @id_list_url "/relation/following_id_list"
  @followers_list "/relation/followers_list"
  @followers_id_list "/relation/followers_id_list"
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

  def following_list(conn, %{"user_id" => user_id}) do
    map = 
      @db_domain_url <> @api_url <> @list_url <> "?user_id=" <> to_string(user_id)
      |> get_request()

    json(conn, map)
  end

  def following_id_list(conn, %{"user_id" => user_id}) do
    map = 
      @db_domain_url <> @api_url <> @id_list_url <> "?user_id=" <> to_string(user_id)
      |> get_request()

    json(conn, map)
  end

  def followers_list(conn, %{"user_id" => user_id}) do
    map = 
      @db_domain_url <> @api_url <> @followers_list <> "?user_id=" <> to_string(user_id)
      |> get_request()

    json(conn, map)
  end

  def followers_id_list(conn, %{"user_id" => user_id}) do
    map = 
      @db_domain_url <> @api_url <> @followers_id_list <> "?user_id=" <> to_string(user_id)
      |> get_request()

    json(conn, map)
  end
end