defmodule Pappap.Online do
  @moduledoc """
  オンライン情報を管理するためのやつ
  #FIXME: いらんかも
  """
  import Ecto.Query, warn: false

  alias Pappap.Repo
  alias Pappap.Online.OnlineUser

  def list_online_users(), do: Repo.all(OnlineUser)

  @doc """
  Function for handling online users.
  """
  def join(user_id) do
    if get_online_users(user_id) == [] do
      attrs = %{user_id: user_id}
      %OnlineUser{}
      |> OnlineUser.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Get online users.
  """
  defp get_online_users(user_id) do
    OnlineUser
    |> where([ou], ou.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Function for handline offline users.
  """
  def leave(user_id) do
    unless get_online_users(user_id) == [] do
      OnlineUser
      |> where([ou], ou.user_id == ^user_id)
      |> Repo.delete_all()
    end
  end
end
