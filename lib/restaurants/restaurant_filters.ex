defmodule Restaurants.RestaurantFilters do
  @moduledoc """
  Restaurant filters
  """
  @behaviour Restaurants.Behaviors.Filter

  alias Restaurants.Behaviors.Filter
  alias Ecto.{Query, Queryable}

  import Ecto.Query, warn: false

  @impl Filter
  @spec apply(Queryable.t(), map()) :: Query.t()
  def apply(query, params) do
    Filter.apply(query, params, &apply_key/3)
  end

  defp apply_key(query, _, ""), do: query

  defp apply_key(query, "search", search),
    do:
      where(
        query,
        [restaurant],
        ilike(restaurant.name, ^"%#{search}%") or ilike(restaurant.site, ^"%#{search}%")
      )

  defp apply_key(query, "lat", lat),
    do: where(query, [restaurant], restaurant.lat == ^lat)

  defp apply_key(query, "lng", lng),
    do: where(query, [restaurant], restaurant.lng == ^lng)

  defp apply_key(query, _, _), do: query
end
