defmodule LaterWeb.FileController do
  use LaterWeb, :controller
  require Logger

  @storage Application.fetch_env!(:later, Later.Storage)[:storage_module]

  # curl -XPOST -H Content-Type: application/octet-stream --data-binary "@comtruise.jpg" localhost:4000/files
  def new(conn, _params) do
    {:ok, file, conn} = Plug.Conn.read_body(conn)

    file_hash = :crypto.hash(:sha512, file) |> Base.encode16(case: :lower)

    public_token = :crypto.strong_rand_bytes(64) |> Base.encode16(case: :lower)

    private_token = :crypto.strong_rand_bytes(64) |> Base.encode16(case: :lower)

    private_token_hash = Argon2.hash_pwd_salt(private_token)

    case @storage.put(file_hash, file) do
      {:ok, location} ->
        Later.Files.create_file!(%{
          file_hash: file_hash,
          private_token_hash: private_token_hash,
          public_token: public_token,
          location: location
        })

        conn
        |> put_status(201)
        |> json(%{
          "hash" => file_hash,
          "private_token" => private_token,
          "public_token" => public_token
        })

      {:error, _e} ->
        conn
        |> put_status(500)
        |> text("something went wrong trying to create a file")
    end
  end

  def release_on(
        conn,
        %{"public_token" => public_token, "private_token" => private_token, "cron" => cron} =
          _params
      ) do
    with %Later.File{} = file <- Later.Files.get_file_by(%{public_token: public_token}),
         {:ok, ^file} <- Argon2.check_pass(file, private_token, hash_key: :private_token_hash),
         {:ok, _cs} <- Later.Files.add_schedule(%{cron_expression: cron, file_id: file.id}),
         %Later.File{} = file <- Later.Files.get_file_by(%{public_token: public_token}) do
      Later.SchedulerStarter.new_job(file)

      conn
      |> put_status(200)
      |> text("ok")
    else
      _ ->
        conn |> put_status(404) |> text("not found")
    end
  end

  def keep_private(
        conn,
        %{"public_token" => public_token, "private_token" => private_token} = _params
      ) do
    with %Later.File{} = file <- Later.Files.get_file_by(%{public_token: public_token}),
         {:ok, ^file} <- Argon2.check_pass(file, private_token, hash_key: :private_token_hash) do
      number_of_times_snoozed =
        if file.public_on_next_tick do
          Later.Files.keep_private_on_next_tick!(file)
          %Later.File{} = new_file = Later.Files.get_file_by(%{public_token: public_token})
          new_file.number_of_times_snoozed + 1
        else
          file.number_of_times_snoozed
        end

      conn
      |> put_status(200)
      |> json(%{"number_of_times_snoozed" => number_of_times_snoozed})
    end
  end

  def info(conn, %{"public_token" => public_token, "private_token" => private_token} = _params) do
    with %Later.File{} = file <- Later.Files.get_file_by(%{public_token: public_token}),
         {:ok, ^file} <- Argon2.check_pass(file, private_token, hash_key: :private_token_hash) do
      {:ok, datetime} =
        file.scheduler_tick.cron_expression
        |> Crontab.CronExpression.Parser.parse!()
        |> Crontab.Scheduler.get_next_run_date()

      next_run_time = Timex.to_datetime(datetime)

      conn
      |> put_status(200)
      |> json(%{"next_run_time" => next_run_time})
    else
      _ ->
        conn |> put_status(404) |> text("not found")
    end
  end

  def get(conn, %{"public_token" => public_token} = _params) do
    case Later.Files.get_file_by(%{public_token: public_token}) do
      %Later.File{} = file ->
        conn
        |> put_status(200)
        |> json(%{
          "hash" => file.file_hash,
          "file_location" => file.location,
          "public_token" => "public_token",
          "uploaded_at" => file.inserted_at
        })

      _ ->
        conn |> put_status(404) |> text("not found")
    end
  end

  def delete(conn, %{"public_token" => public_token, "private_token" => private_token} = _params) do
    with %Later.File{} = file <- Later.Files.get_file_by(%{public_token: public_token}),
         {:ok, ^file} <- Argon2.check_pass(file, private_token, hash_key: :private_token_hash) do
      Later.Files.delete!(file)
      Later.SchedulerStarter.delete_job(file.public_token)

      conn
      |> put_status(200)
      |> text("ok")
    else
      _ ->
        conn |> put_status(404) |> text("not found")
    end
  end
end
