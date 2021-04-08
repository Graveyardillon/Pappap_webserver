defmodule Pappap.Online.OnlineUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "online_users" do
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(online_user, attrs) do
    online_user
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
    |> unique_constraint(:user_id)
  end
end
