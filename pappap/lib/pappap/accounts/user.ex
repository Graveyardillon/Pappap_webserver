defmodule Pappap.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pappap.Accounts.Device

  schema "users" do
    field :user_id, :string
    field :is_online, :boolean, default: false
    has_one :device, Device

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:user_id, :is_online])
  end
end
