defmodule PappapWeb.AuthController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url)

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/user/" <> path
    |> get_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Pass a post request to database server.
  """
  def pass_post_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/user/" <> path
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Signup process
  """
  def signup(conn, params) do
    @db_domain_url <> "/api/user/signup"
    |> send_json(params)
    ~> response

    if response.body["result"] do
      Task.async(fn ->
        user_id = response.body["data"]["id"]
        params = %{
          "notif" => %{
            "user_id" => user_id,
            "process_id" => "COMMON",
            "title" => "e-playersへようこそ！",
            "body_text" => "もしよければコミュニティに参加してアプリの改善に力を貸してください！\nhttps://discord.gg/cfZw6EAYrv",
            "data" => nil
          }
        }

        @db_domain_url <> "/api/notification/create"
        |> send_json(params)
      end)
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end
end
