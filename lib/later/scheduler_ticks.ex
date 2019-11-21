defmodule Later.SchedulerTicks do
  alias Later.Repo
  alias Later.SchedulerTick, as: ST

  def create(attrs) do
    %ST{}
    |> ST.changeset(attrs)
    |> Repo.insert()
  end
end
