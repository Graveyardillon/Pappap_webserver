defmodule Pappap.Notifications do
  alias Pappap.Notifications

  def topic, do: "Papillon-inc.eplayers"

  def push(message, device_id) do
    Pigeon.APNS.Notification.new(message, device_id, Notifications.topic())
    |> Pigeon.APNS.push()
  end
end