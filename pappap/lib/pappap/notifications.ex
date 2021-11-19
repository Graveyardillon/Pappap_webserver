defmodule Pappap.Notifications do
  use Common.Tools

  require Logger

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @create_notif "/notification/create"

  def topic, do: "PapillonKK.e-players"

  def create(user_id, message, process_id \\ -1, data \\ "") do
    params = %{"notif" => %{"user_id" => user_id, "title" => message, "process_id" => process_id, "data" => data}}

    @db_domain_url <> @api_url <> @create_notif
    |> send_json(params)
  end
end
