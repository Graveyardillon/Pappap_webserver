defmodule PappapWeb.AssistantController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @assistant_url "/assistant"
  @assistant_log_url "/assistant_log"

  def create_assistant(conn, params) do
    @db_domain_url <> @api_url <> @assistant_url
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)
  end
end
