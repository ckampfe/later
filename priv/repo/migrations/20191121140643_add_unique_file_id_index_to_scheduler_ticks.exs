defmodule Later.Repo.Migrations.AddUniqueFileIdIndexToSchedulerTicks do
  use Ecto.Migration

  def change do
    create unique_index(:scheduler_ticks, [:file_id])
  end
end
