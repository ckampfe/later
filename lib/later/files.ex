defmodule Later.Files do
  import Ecto.Query
  alias Later.Repo
  alias Later.File, as: LF

  def create_file!(attrs) do
    %LF{}
    |> LF.changeset(attrs)
    |> Repo.insert!()
  end

  def create_file(attrs) do
    %LF{}
    |> LF.changeset(attrs)
    |> Repo.insert()
  end

  def get_file_by(args) do
    LF
    |> Repo.get_by(args)
    |> Repo.preload([:scheduler_tick])
  end

  def get_public_file_by(args) do
    LF
    |> where([f], not is_nil(f.public_at))
    |> Repo.get_by(args)
    |> Repo.preload([:scheduler_tick])
  end

  def keep_private_on_next_tick!(file) do
    file
    |> LF.changeset(%{
      public_on_next_tick: false,
      number_of_times_snoozed: file.number_of_times_snoozed + 1
    })
    |> Repo.update!()
  end

  def make_public!(file) do
    file
    |> LF.changeset(%{public_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def make_public_on_next_tick!(file) do
    file
    |> LF.changeset(%{public_on_next_tick: true})
    |> Repo.update!()
  end

  def add_schedule(schedule_attrs) do
    Later.SchedulerTicks.create(schedule_attrs)
  end

  def add_job_ref!(file, job_ref) do
    job_id = job_ref |> :erlang.ref_to_list() |> to_string()

    file
    |> LF.changeset(%{job_id: job_id})
    |> Repo.update!()
  end

  def delete!(file) do
    file
    |> LF.changeset(%{deleted_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  def files_needing_to_be_activated() do
    Later.File
    |> where([f], is_nil(f.deleted_at))
    |> where([f], is_nil(f.public_at))
    |> join(:inner, [f], s in Later.SchedulerTick, on: f.id == s.file_id)
    |> preload(:scheduler_tick)
    |> select([f, s], f)
    |> Repo.all()
  end
end
