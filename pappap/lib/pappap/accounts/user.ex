defmodule Pappap.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :is_online, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:is_online])
    |> validate_required([:is_online])
  end
end
