defmodule Common.Tools do
  use Timex

  defmacro __using__(_opts) do
    quote do
      def send_json(url, params) do
        content_type = [{"Content-Type", "application/json"}]

        with {:ok, attrs} <- Poison.decode(params),
          {:ok, response} <- HTTPoison.post(url, attrs, content_type),
          {:ok, body} <- Poison.decode(response.body) do
            body
        else
          {:error, {reason, _, _}} ->
            %{
              "result" => false,
              "reason" => reason
            }
          {:error, reason} ->
            %{
              "result" => false,
              "reason" => reason
            }
          _ ->
            %{
              "result" => false,
              "reason" => "Unexpected error"
            }
        end
      end

      #FIXME: この関数をtournament_controllerから別で書く必要はないかも
      def send_tournament_multipart(url, params, file_path) do
        content_type = [{"Content-Type", "multipart/form-data"}]

        tournament = if is_binary(params["tournament"]) do
          params["tournament"]
        else
          Poison.encode!(params["tournament"])
        end

        IO.inspect(tournament)

        form = [{:file, file_path}, {"tournament", tournament}]

        with {:ok, response} <- HTTPoison.post(
          url,
          {:multipart, form},
          content_type
        ),
          {:ok, body} <- Poison.decode(response.body) do
            body
        else
          {:error, {reason, _, _}} ->
            %{
              "result" => false,
              "reason" => reason
            }
          {:error, reason} ->
            %{
              "result" => false,
              "reason" => reason
            }
          _ ->
            %{
              "result" => false,
              "reason" => "Unexpected error"
            }
        end
      end
    end
  end
end