defmodule PappapWeb.AuthController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url "http://localhost:4000"
  @api_url "/api"
  @signup_url "/user/signup"
  @signin_url "/user/login"

  def signup(conn, params) do
    map = 
      @db_domain_url <> @api_url <> @signup_url
      |> send_json(params)

    json(conn, map)
  end

  def signin(conn, params) do
    map = 
      @db_domain_url <> @api_url <> @signin_url
      |> send_json(params)

    json(conn, map)
  end
end