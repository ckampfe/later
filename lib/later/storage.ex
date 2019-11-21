defmodule Later.Storage do
  # file hash, file data
  @callback put(String.t(), binary()) :: {:ok, binary()} | {:error, atom()}
  @callback delete(String.t()) :: :ok | {:error, String.t()}
  @callback get(String.t()) :: {:ok, binary()} | {:error, atom()}
end
