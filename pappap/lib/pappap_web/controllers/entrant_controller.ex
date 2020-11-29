defmodule PappapWeb.EntrantController do
  use PappapWeb, :controller
  use Common.Tools
  @db_domain_url Application.get_env(:pappap, :db_domain_url) <> "/api"
  @entrant_url "/entrant"
  @entrant_log_url "/entrant_log"
  @rank_url "/rank"

  def create(conn, params) do
    map =
      @db_domain_url <> @entrant_url
      |> send_json(params)

    if map["result"] do
      @db_domain_url <> @entrant_log_url
      |> send_json(map)
      |> IO.inspect
    end
    
    json(conn, map)
  end

  def show_rank(conn, %{"tournament_id" => tournament_id, "user_id" => user_id}) do
    rank =
      @db_domain_url <> @entrant_url <> @rank_url <> "/" <> to_string(tournament_id) <> "/" <> to_string(user_id)
      |> get_request()
    json(conn, rank)
  end
end