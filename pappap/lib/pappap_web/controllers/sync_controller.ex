defmodule PappapWeb.SyncController do
  use PappapWeb, :controller
  use Common.Tools

  import Common.Sperm

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @sync_url "/sync"
  @content_type [{"Content-Type", "application/json"}]

  def sync(conn, params) do
    @db_domain_url <> @api_url <> @sync_url
    |> send_json(params)
    ~> response

    conn
    |> put_status(response.status_code)
    |> json(response.body)

    # with {:ok, attrs} <- Poison.encode(params),
    #   {:ok, response} <- HTTPoison.post(url, attrs, @content_type),
    #   {:ok, body} <- Poison.decode(response.body) do
    #     json(conn, body)
    #   else
    #     {:error, reason} ->
    #       map = %{
    #         "result" => false,
    #         "reason" => reason
    #       }
    #       json(conn, map)
    #     _ ->
    #       map = %{
    #         "result" => false,
    #         "reason" => "Unexpected error"
    #       }
    #       json(conn, map)
    # end
  end
end
