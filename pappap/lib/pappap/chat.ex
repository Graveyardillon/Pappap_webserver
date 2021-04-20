defmodule Pappap.Chat do
  use PappapWeb, :controller

  require Logger

  @db_domain_url Application.get_env(:pappap, :db_domain_url)
  @api_url "/api"
  @create_dialogue_url "/chat/create_dialogue"
  @content_type [{"Content-Type", "application/json"}]

  def send_chat(params) do
    url = @db_domain_url <> @api_url <> @create_dialogue_url

    with {:ok, attrs} <- Poison.encode(params),
      {:ok, response} <- HTTPoison.post(url, attrs, @content_type),
      {:ok, body} <- Poison.decode(response.body) do
      Logger.info("Sent chat to DBServer!")
      IO.inspect(body, label: :body)
      {:ok, body}
    else
      {:error, reason} ->
        map = %{
          "result" => false,
          "reason" => reason,
          "error_no" => 10000
        }
        Logger.warn("Failed to send chat to DBServer")
        IO.inspect(map, label: :result)
        {:error, map}
      _ ->
        map = %{
          "result" => false,
          "reason" => "Unexpected error",
          "error_no" => 10000
        }
        Logger.warn("Failed to send chat to DBServer")
        IO.inspect(map, label: :result)
        {:error, map}
    end
  end
end
