defmodule Later.Repo.Migrations.CreateFilesTable do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :file_hash, :string, null: false
      add :private_token_hash, :string, null: false
      add :location, :string, null: false
      add :public_token, :string, null: false
      add :public_at, :utc_datetime_usec
      add :public_on_next_tick, :boolean, null: false, default: true
      add :number_of_times_snoozed, :integer, null: false, default: 0
      add :deleted_at, :utc_datetime_usec

      timestamps(type: :timestamptz)
    end
  end
end
