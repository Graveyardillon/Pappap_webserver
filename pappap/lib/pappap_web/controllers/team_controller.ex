defmodule PappapWeb.TeamController do
  use PappapWeb, :controller
  use Common.Tools
  use Timex

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url)

  def show(conn, params) do
    @db_domain_url <> "/api/team"
    |> get_parammed_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/api/team/" <> path
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

    @db_domain_url <> "/api/team/" <> path
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Delete a team.
  """
  def pass_delete_request(conn, params) do
    path = params["string"]

    @db_domain_url <> "/team/" <> path
    |> delete_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Create a team.
  TODO: pendingのチャンネルに参加
  """
  def create(conn, params) do
    @db_domain_url <> "/api/team/"
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Delete a team
  """
  def delete(conn, params) do
    @db_domain_url <> "/api/team/"
    |> delete_request(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end

  @doc """
  Confirm invitation.
  """
  def confirm_invitation(conn, params) do
    @db_domain_url <> "/api/team/invitation_confirm"
    |> send_json(params)
    ~> response

    if response.body["is_confirmed"] do
      topic = "pending_tournament:#{response.body["tournament_id"]}"
      PappapWeb.Endpoint.broadcast(topic, "confirmed", %{tournament_id: params["tournament_id"], msg: "confirmed"})
    end

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end
end
