defmodule Later.Repo.Migrations.CreateSchedulerTicksTable do
  use Ecto.Migration

  def change do
    create table(:scheduler_ticks) do
      add :cron_expression, :string, null: false
      add :active, :boolean, null: false, default: true
      add :deleted_at, :utc_datetime
      add :file_id, references(:files)

      timestamps(type: :timestamptz)
    end
  end
end
