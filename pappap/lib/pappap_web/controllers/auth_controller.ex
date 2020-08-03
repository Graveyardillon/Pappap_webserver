defmodule PappapWeb.AuthController do
  use PappapWeb, :controller

  @db_domain_url "http://localhost:4001"
  @api_url "/api"
  @signup_url "/user"
  @signin_url "/signin"
  @content_type [{"Content-Type", "application/json"}]

  def signup(conn, params) do
    url = @db_domain_url <> @api_url <> @signup_url

    with {:ok, attrs} <- Poison.encode(params),
      {:ok, response} <- HTTPoison.post(url, attrs, @content_type),
      {:ok, body} <- Poison.decode(response.body) do
      json(conn, body)
    else
      {:error, reason} ->
        map = %{
          "result" => false,
          "reason" => reason,
          "error_no" => 10000
        }
        json(conn, map)

      _ ->
        map = %{
          "result" => false,
          "reason" => "Unexpected error",
          "error_no" => 10000
        }
        json(conn, map)
    end
  end

  def signin(conn, params) do
    url = @db_domain_url <> @api_url <> @signin_url
    attrs = Poison.encode!(params)

    {:ok, response} = HTTPoison.post(url, attrs, @content_type)
    b = Poison.decode!(response.body)

    json(conn, b)
  end
end