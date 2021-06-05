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

  def create(user_id, message, process_code \\ -1, data \\ "") do
    params = %{"notif" => %{"user_id" => user_id, "content" => message, "process_code" => process_code, "data" => data}}

    @db_domain_url <> @api_url <> @create_notif
    |> send_json(params)
    # @db_domain_url <> @api_url <> @create_log
    # |> send_json(params)
  end

  def push(message, device_id, process_code \\ -1, data \\ "") do
    message
    |> Pigeon.APNS.Notification.new(device_id, Notifications.topic())
    |> Pigeon.APNS.Notification.put_alert(%{"body" => message, "title" => "ユーザー名"})
    |> Pigeon.APNS.push()
    |> IO.inspect()

    device = Accounts.from_device_id(device_id)
    params = %{"notif" => %{"user_id" => device.user_id, "content" => message, "process_code" => process_code, "data" => data}}
    Logger.debug("通知を" <> to_string(device.user_id) <> "に送信しました。")

    Task.async(fn ->
      @db_domain_url <> @api_url <> @create_notif
      |> send_json(params)
    end)
  end
end
