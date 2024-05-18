defmodule Restaurants.Behaviors.Filter do
  @moduledoc """
  Behaviour for filtering Restaurants.
  """
  alias Ecto.Query
  alias Ecto.Queryable

  @callback apply(queryable :: Queryable.t(), params :: map()) :: Query.t()
  @type apply_key :: (queryable :: Queryable.t(), key :: atom(), value :: any() -> Query.t())

  @spec apply(Queryable.t(), map(), apply_key()) :: Query.t()
  def apply(queryable, params, apply_key) do
    Enum.reduce(params, queryable, fn {key, value}, query -> apply_key.(query, key, value) end)
  end
end
