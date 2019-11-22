defmodule Later.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field(:file_hash, :string)
    field(:private_token_hash, :string)
    field(:location, :string)
    field(:public_token, :string)
    field(:public_on_next_tick, :boolean)
    field(:job_id, :string)
    field(:number_of_times_snoozed, :integer)
    field(:public_at, :utc_datetime_usec)
    field(:deleted_at, :utc_datetime_usec)

    has_one(:scheduler_tick, Later.SchedulerTick)

    timestamps(type: :utc_datetime_usec)
  end

  def allowed_attrs,
    do: __MODULE__.__schema__(:fields) -- [:inserted_at, :updated_at, :id]

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, allowed_attrs())
    |> validate_required([:public_token, :private_token_hash, :location])
  end
end
