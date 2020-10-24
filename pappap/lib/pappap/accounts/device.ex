defmodule Pappap.Accounts.Device do
  use Ecto.Schema
  import Ecto.Changeset

  schema "devices" do
    field :user_id, :integer
    field :device_id, :string

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:user_id, :device_id])
    |> validate_required([:user_id, :device_id])
    |> unique_constraint(:device_id)
  end
end
