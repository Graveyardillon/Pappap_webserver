defmodule Pappap.Notifications do
  alias Pappap.Notifications
  alias Pappap.Accounts
  use Common.Tools

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @create_notif "/notif/create"
  @create_log "/notif_log/create"

  def topic, do: "Papillon-inc.eplayers"

  def push(message, device_id, process_code \\ -1, data \\ "") do
    Pigeon.APNS.Notification.new(message, device_id, Notifications.topic())
    |> Pigeon.APNS.push()

    device = Accounts.from_device_id(device_id)
      params = %{"notif" => %{"user_id" => device.user_id, "content" => message, "process_code" => process_code, "data" => data}}

    Task.start_link(fn ->
      @db_domain_url <> @api_url <> @create_notif
        |> send_json(params)
    end)

    Task.start_link(fn ->
      @db_domain_url <> @api_url <> @create_log
        |> send_json(params)
    end)
  end
end
