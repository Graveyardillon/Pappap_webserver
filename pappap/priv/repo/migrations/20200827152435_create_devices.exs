defmodule Pappap.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices) do
      add :user_id, :integer
      add :device_id, :string

      timestamps()
    end

    create unique_index(:devices, [:device_id])
  end
end
