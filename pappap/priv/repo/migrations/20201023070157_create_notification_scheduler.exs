defmodule Pappap.Repo.Migrations.CreateScheduler do
  use Ecto.Migration

  def change do
    create table(:notification_scheduler) do
      add :device_id, :string
      add :seconds_after, :integer
    end
  end
end
