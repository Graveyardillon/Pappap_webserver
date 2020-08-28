defmodule Pappap.Chat do
  use PappapWeb, :controller

  @db_domain_url "http://localhost:4000"
  @api_url "/api"
  @create_dialogue_url "/chat/create_dialogue"
  @content_type [{"Content-Type", "application/json"}]

  def send_chat(params) do
    url = @db_domain_url <> @api_url <> @create_dialogue_url

    with {:ok, attrs} <- Poison.encode(params),
      {:ok, response} <- HTTPoison.post(url, attrs, @content_type),
      {:ok, body} <- Poison.decode(response.body) do
      body
    else
      {:error, reason} ->
        %{
          "result" => false,
          "reason" => reason,
          "error_no" => 10000
        }
      _ ->
        %{
          "result" => false,
          "reason" => "Unexpected error",
          "error_no" => 10000
        }
    end
  end
end