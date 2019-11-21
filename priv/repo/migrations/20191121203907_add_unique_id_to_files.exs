defmodule Later.Repo.Migrations.AddUniqueIdToFiles do
  use Ecto.Migration

  def change do
    create unique_index(:files, [:public_token])
  end
end
