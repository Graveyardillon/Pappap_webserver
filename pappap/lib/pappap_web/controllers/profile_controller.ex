defmodule PappapWeb.ProfileController do
    use PappapWeb, :controller
    @db_domain_url Application.get_env(:pappap, :db_domain_url)
    @api_url "/api"
    @profile_url  "/profile"
    @update_url "/update"
    @content_type [{"Content-Type", "application/json"}]

    def send(conn,params) do
        url = @db_domain_url <> @api_url <> @profile_url <> @update_url

        with {:ok, attrs} <- Poison.encode(params),
        {:ok, response} <- HTTPoison.post(url, attrs, @content_type) do
            json(conn, %{msg: "Succeed"})
        end

    end
end