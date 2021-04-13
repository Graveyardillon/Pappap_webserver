defmodule Pappap.Notifications do
  use Common.Tools

  require Logger

  alias Pappap.{
    Notifications,
    Accounts
  }

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @create_notif "/notification/create"
  @create_log "/notification_log/create"

  def topic, do: "PapillonKK.e-players"

  def push(message, device_id, process_code \\ -1, data \\ "") do
    Pigeon.APNS.Notification.new(message, device_id, Notifications.topic())
    |> Pigeon.APNS.push()

    device = Accounts.from_device_id(device_id)
    params = %{"notif" => %{"user_id" => device.user_id, "content" => message, "process_code" => process_code, "data" => data}}
    Logger.debug("通知を" <> to_string(device.user_id) <> "に送信しました。")

    Task.async(fn ->
      @db_domain_url <> @api_url <> @create_notif
        |> send_json(params)
    end)

    Task.async(fn ->
      @db_domain_url <> @api_url <> @create_log
        |> send_json(params)
    end)
  end
end
