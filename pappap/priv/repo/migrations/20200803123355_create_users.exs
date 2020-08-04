defmodule Pappap.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :user_id, :string, null: false
      add :is_online, :boolean, default: false, null: false

      timestamps()
    end
  end
end
