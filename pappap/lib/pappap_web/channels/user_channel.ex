defmodule PappapWeb.UserChannel do
  use Phoenix.Channel

  def join("user:" <> _user_id, %{"token" => token}, socket) do
    if authorized?(token) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized or invalid connection"}}
    end
    # {user_id, _} = Integer.parse(user_id)

    # %{id: id} = socket.assigns.user

    # if id == user_id and authorized?(token) do
    #   {:ok, socket}
    # else
    #   {:error, %{reason: "unauthorized or invalid comer"}}
    # end
  end

  # TODO: ここにトークンによる認証処理を書く。
  defp authorized?(token) do
    token == Application.get_env(:pappap, :user_ws_token)
  end
end
