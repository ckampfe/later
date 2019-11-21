defmodule Later.FileStorage do
  @behaviour Later.Storage

  @impl Later.Storage
  def put(key, data) do
    path = Path.join("/tmp", key)

    case File.write(path, data) do
      :ok ->
        {:ok, path}

      e ->
        e
    end
  end

  @impl Later.Storage
  def delete(_path) do
    :ok
  end

  @impl Later.Storage
  def get(location) do
    File.read(location)
  end
end
