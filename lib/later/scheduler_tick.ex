defmodule Later.SchedulerTick do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scheduler_ticks" do
    field(:cron_expression, :string)
    field(:active, :boolean)
    field(:deleted_at, :utc_datetime_usec)

    belongs_to(:file, Later.File)

    timestamps(type: :utc_datetime_usec)
  end

  def allowed_attrs,
    do: __MODULE__.__schema__(:fields) -- [:inserted_at, :updated_at, :id]

  @doc false
  def changeset(scheduler_tick, attrs) do
    scheduler_tick
    |> cast(attrs, allowed_attrs())
    |> validate_required([:cron_expression, :file_id])

    # |> unique_constraint(:file_id)
  end
end
