defmodule PappapWeb.TeamController do
  use PappapWeb, :controller
  use Common.Tools
  use Timex

  @db_domain_url Application.get_env(:pappap, :db_domain_url)

  def show(conn, params) do
    map =
      @db_domain_url <> "/api/team"
      |> get_parammed_request(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end


  @doc """
  Pass a get request to database server.
  """
  def pass_get_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/team/" <> path
      |> get_parammed_request(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Pass a post request to database server.
  """
  def pass_post_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/api/team/" <> path
      |> send_json(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Delete a team.
  """
  def pass_delete_request(conn, params) do
    path = params["string"]

    map =
      @db_domain_url <> "/team/" <> path
      |> delete_request(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Create a team.
  TODO: pendingのチャンネルに参加
  """
  def create(conn, params) do
    map =
      @db_domain_url <> "/api/team/"
      |> send_json(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Delete a team
  """
  def delete(conn, params) do
    map =
      @db_domain_url <> "/api/team/"
      |> delete_request(params)

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end

  @doc """
  Confirm invitation.
  """
  def confirm_invitation(conn, params) do
    map =
      @db_domain_url <> "/api/team/invitation_confirm"
      |> send_json(params)

    if map["is_confirmed"] do
      IO.inspect(map, label: :worked!)
      topic = "pending_tournament:#{map["tournament_id"]}"
      |> IO.inspect()
      PappapWeb.Endpoint.broadcast(topic, "confirmed", %{tournament_id: params["tournament_id"], msg: "confirmed"})
    end

    case map do
      %{"result" => false, "reason" => _reason} ->
        conn
        |> put_status(500)
        |> json(map)
      map ->
        json(conn, map)
    end
  end
end
