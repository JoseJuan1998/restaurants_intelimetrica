defmodule Restaurants.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
      import EctoEnum

      alias Restaurants.Repo

      @timestamps_opts [type: :utc_datetime_usec]
      @type t :: %__MODULE__{}
    end
  end
end
