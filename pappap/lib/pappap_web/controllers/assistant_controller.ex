defmodule PappapWeb.AssistantController do
  use PappapWeb, :controller
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @assistant_url "/assistant"
  @assistant_log_url "/assistant_log"

  def create_assistant(conn, params) do
    map =
      @db_domain_url <> @api_url <> @assistant_url
      |> send_json(params)
      
    IO.inspect(params["assistant"]["tournament_id"],label: :params)
    # edited =
    #   map["data"]
    #   |>Enum.map(fn x -> 
    #     Map.put(x, "tournament_id", map["data"]["tournament_id"]
    #     |>Map.put("create_time",map["data"]["create_time"]
    #     |>Map.put("update_time",map["data"][]))) end)
    @db_domain_url <> @api_url <> @assistant_log_url
    |> send_json(map)

    json(conn, map)
  end
end