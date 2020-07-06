defmodule PappapWeb.AuthController do
  use PappapWeb, :controller

  @db_domain_url "http://localhost:4001"
  @api_url "/api"
  @signup_url "/signup"
  @signin_url "/signin"
  @content_type [{"Content-Type", "application/json"}]

  def signup(conn, params) do
    url = @db_domain_url <> @api_url <> @signup_url
    attrs = Poison.encode!(params)

    {:ok, response} = HTTPoison.post(url, attrs, @content_type)
    b = Poison.decode!(response.body)

    json(conn, b)
  end

  def signin(conn, params) do
    url = @db_domain_url <> @api_url <> @signin_url
    attrs = Poison.encode!(params)

    {:ok, response} = HTTPoison.post(url, attrs, @content_type)
    b = Poison.decode!(response.body)

    json(conn, b)
  end
end