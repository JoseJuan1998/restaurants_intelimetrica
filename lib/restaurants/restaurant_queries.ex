defmodule Restaurants.RestaurantQueries do
  alias Restaurants.Repo
  alias Restaurants.Restaurant
  alias Restaurants.RestaurantFilters

  import Ecto.Query, warn: false

  @page_limit_default 10
  @page_limit_max 100

  # --- Restaurants CRUD -------------------------------------------------------

  @spec get_page(map()) :: map()
  @doc section: :restaurants
  def get_page(attrs \\ %{})

  def get_page(attrs) do
    Restaurant
    |> RestaurantFilters.apply(attrs)
    |> paginate(attrs)
  end

  @spec get_restaurant(Ecto.UUID.t()) :: {:ok, Restaurant.t()} | {:error, any()}
  @doc section: :restaurants
  def get_restaurant(id) do
    with {:ok, uuid} <- Ecto.UUID.cast(id),
         restaurant = %Restaurant{} <- Repo.get(Restaurant, uuid) do
      {:ok, restaurant}
    else
      _ -> {:error, :not_found}
    end
  end

  @spec create_restaurant(map()) :: {:ok, Restaurant.t()} | {:error, any()}
  @doc section: :restaurants
  def create_restaurant(params \\ %{}) do
    %Restaurant{}
    |> Restaurant.changeset(params)
    |> Repo.insert()
  end

  @spec update_restaurant(Ecto.UUID.t(), map()) :: {:ok, Restaurant.t()} | {:error, any()}
  @doc section: :restaurants
  def update_restaurant(id, params) do
    with {:ok, restaurant} <- get_restaurant(id),
         {:ok, updated_restaurant} <-
           restaurant
           |> Restaurant.changeset(params)
           |> Repo.update() do
      {:ok, updated_restaurant}
    end
  end

  @spec delete_restaurant(Ecto.UUID.t()) :: {:ok, Restaurant.t()} | {:error, any()}
  @doc section: :restaurants
  def delete_restaurant(id) do
    with {:ok, restaurant} <- get_restaurant(id),
         {:ok, _} <- Repo.delete(restaurant) do
      {:ok, restaurant}
    end
  end

  # --- Restaurants geo location --------------------------------------------

  @spec get_nearest_restaurants(float(), float(), integer()) :: map()
  @doc section: :restaurants
  def get_nearest_restaurants(lat, lng, radius) do
    lat = if is_binary(lat), do: String.to_float(lat), else: lat
    lng = if is_binary(lng), do: String.to_float(lng), else: lng
    radius = if is_binary(radius), do: String.to_integer(radius), else: radius

    query =
      from r in Restaurant,
        where:
          fragment(
            """
            ST_DWithin(
              ST_SetSRID(ST_MakePoint(?, ?), 4326)::geography,
              ST_SetSRID(ST_MakePoint(cast(r0.lng as double precision), cast(r0.lat as double precision)), 4326)::geography,
              ?
            )
            """,
            ^lng,
            ^lat,
            ^radius
          ),
        select: %{
          count: count(r.id),
          avg: fragment("avg(cast(r0.rating as double precision))"),
          std: fragment("stddev(cast(r0.rating as double precision))")
        }

    Repo.one(query)
  end

  # === Private ================================================================

  defp paginate(query, attrs) do
    {limit, page} = page_options(attrs)

    offset = (page - 1) * limit

    records =
      query
      |> limit([_record], ^limit)
      |> offset([_record], ^offset)
      |> Repo.all()

    total_count =
      query
      |> distinct([module], module.id)
      |> Repo.aggregate(:count)

    %{
      records: records,
      count: length(records),
      page: page,
      total_count: total_count,
      total_pages: (total_count / limit) |> ceil(),
      limit: limit,
      offset: offset,
      search: attrs["search"]
    }
  end

  defp page_options(attrs),
    do: {
      case Integer.parse(attrs["limit"] || "") do
        {int, ""} when int > @page_limit_max -> @page_limit_max
        {int, ""} when int > 0 -> int
        _ -> @page_limit_default
      end,
      case Integer.parse(attrs["page"] || "") do
        {int, ""} when int > 0 -> int
        _ -> 1
      end
    }
end
