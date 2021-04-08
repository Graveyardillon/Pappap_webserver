defmodule Pappap.Repo.Migrations.CreateOnlineTable do
  use Ecto.Migration

  def change do
    create table(:online_users) do
      add :user_id, :integer

      timestamps()
    end
  end
end
