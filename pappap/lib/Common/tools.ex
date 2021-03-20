defmodule Common.Tools do
  use Timex

  defmacro __using__(_opts) do
    quote do
      def get_request(url) do
        content_type = [{"Content-Type", "application/json"}]
        with {:ok, response} <- HTTPoison.get(url, content_type, [ssl: [{:versions, [:'tlsv1.2']}]]),
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
              "reason" => "unexpected error"
            }
        end
      end

      def get_parammed_request(url, params) do
        content_type = [{"Content-Type", "application/json"}]

        with {:ok, response} <- HTTPoison.get(url, content_type, [ssl: [{:versions, [:'tlsv1.2']}], params: params]),
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
                "reason" => "unexpected error"
              }
          end
      end

      def send_json(url, params) do
        content_type = [{"Content-Type", "application/json"}]

        with {:ok, attrs} <- Poison.encode(params),
          {:ok, response} <- HTTPoison.post(url, attrs, content_type, [ssl: [{:versions, [:'tlsv1.2']}]]),
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
              "reason" => "unexpected error"
            }
        end
      end

      def delete_parammed_request(url, params) do
        content_type = [{"Content-Type", "application/json"}]

        with {:ok, response} <- HTTPoison.delete(url, content_type, [ssl: [{:versions, [:'tlsv1.2']}], params: params]),
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
                "reason" => "unexpected error"
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

        form = [{:file, file_path}, {"tournament", tournament}]

        with {:ok, response} <- HTTPoison.post(
          url,
          {:multipart, form},
          content_type,
          [ssl: [{:versions, [:'tlsv1.2']}]]
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

      def delete_request(url, params) do
        content_type = [{"Content-Type", "application/json"}]

        with {:ok, attrs} <- Poison.encode(params),
          {:ok, response} <- HTTPoison.delete(url, content_type, [ssl: [{:versions, [:'tlsv1.2']}], params: params]),
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
              "reason" => "unexpected error"
            }
        end
      end
    end
  end
end
