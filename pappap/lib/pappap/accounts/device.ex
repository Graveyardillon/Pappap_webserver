defmodule Pappap.Accounts.Device do
  use Ecto.Schema
  import Ecto.Changeset

  alias Pappap.Accounts.User

  schema "devices" do
    field :device_id, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:device_id])
    |> validate_required([:device_id])
  end
end
