defmodule Later.SchedulerStarter do
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    {:ok, args, {:continue, :start_scheduler_jobs}}
  end

  def handle_continue(:start_scheduler_jobs, state) do
    Logger.debug("Searching for unstarted jobs")
    start_unstarted_jobs()
    {:noreply, state}
  end

  def start_unstarted_jobs() do
    active_files = Later.Files.files_needing_to_be_activated()

    Logger.debug("Found #{Enum.count(active_files)} unstarted jobs, starting.")

    Task.async_stream(active_files, fn file ->
      new_job(file)
    end)
    |> Stream.run()
  end

  def new_job(file) do
    cron_schedule =
      file.scheduler_tick.cron_expression
      |> Crontab.CronExpression.Parser.parse!()

    Later.FileScheduler.new_job()
    |> Quantum.Job.set_name(String.to_atom(file.public_token))
    |> Quantum.Job.set_schedule(cron_schedule)
    |> Quantum.Job.set_task(fn ->
      file = Later.Files.get_file_by(%{public_token: file.public_token})

      cond do
        is_nil(file.deleted_at) && is_nil(file.public_at) && file.public_on_next_tick ->
          Later.Files.make_public!(file)
          Later.FileScheduler.delete_job(String.to_atom(file.public_token))
          delete_job(file.public_token)
          Logger.debug("File #{file.public_token} made public.")

        true ->
          Later.Files.make_public_on_next_tick!(file)

          Logger.debug(
            "File #{file.public_token} will be made public next time its job activates."
          )
      end
    end)
    |> Later.FileScheduler.add_job()
  end

  def delete_job(public_token) do
    Later.FileScheduler.delete_job(String.to_atom(public_token))
  end
end
