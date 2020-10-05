defmodule Common.Tools do
defmacro __using__(_opts) do
    quote do
      def sendHTTP(url, params, type) do
        with {:ok, attrs} <- Poison.encode(params),
          {:ok, response} <- HTTPoison.post(url, attrs, type),
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