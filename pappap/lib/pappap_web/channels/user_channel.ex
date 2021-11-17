defmodule PappapWeb.UserChannel do
  use Phoenix.Channel

  def join("user:" <> _user_id, %{"token" => token}, socket) do
    if authorized?(token) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # TODO: ここにトークンによる認証処理を書く。
  defp authorized?(_token) do
    true
  end
end
