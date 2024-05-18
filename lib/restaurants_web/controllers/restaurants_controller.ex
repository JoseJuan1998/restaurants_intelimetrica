defmodule RestaurantsWeb.RestaurantsController do
  use RestaurantsWeb, :controller

  alias Restaurants.RestaurantQueries

  action_fallback RestaurantsWeb.FallbackController

  def page(conn, params) do
    restaurants = RestaurantQueries.get_page(params)

    conn
    |> put_status(:ok)
    |> json(restaurants)
  end

  swagger_path(:page) do
    path(@routes[:page])
    tag("Restaurants")
    produces("application/json")

    description("Returns a list of restaurants.")
    parameter(:page, :query, :integer, "Page number")
    parameter(:limit, :query, :integer, "Page limit")

    parameter(
      :search,
      :query,
      :string,
      "String to search within the restaurant name, site or email"
    )

    parameter(:lat, :query, :number, "Search restaurants by latitude")
    parameter(:lng, :query, :number, "Search restaurants by longitude")
    response(200, "Restaurants list", :Restaurant)
  end

  def get(conn, %{"id" => id}) do
    case RestaurantQueries.get_restaurant(id) do
      {:ok, restaurant} ->
        conn
        |> put_status(:ok)
        |> json(restaurant)

      error ->
        error
    end
  end

  swagger_path(:get) do
    path(@routes[:get])
    tag("Restaurants")
    produces("application/json")

    description("Returns a restaurant by ID.")
    parameter(:id, :path, :string, "Restaurant ID")
    response(200, "Restaurant resource", :Restaurant)
    response(404, "Not found")
  end

  def create(conn, %{"restaurant" => restaurant_params}) do
    case RestaurantQueries.create_restaurant(restaurant_params) do
      {:ok, restaurant} ->
        conn
        |> put_status(201)
        |> json(restaurant)

      error ->
        error
    end
  end

  swagger_path(:create) do
    path(@routes[:create])
    tag("Restaurants")
    produces("application/json")

    description("Creates a new restaurant.")
    parameter(:restaurant, :body, :Restaurant, "Restaurant data")
    response(201, "Restaurant resource", :Restaurant)
    response(422, "Unprocessable entity", :Error)
  end

  def update(conn, %{"id" => id, "restaurant" => restaurant_params}) do
    case RestaurantQueries.update_restaurant(id, restaurant_params) do
      {:ok, restaurant} ->
        conn
        |> put_status(:ok)
        |> json(restaurant)

      error ->
        error
    end
  end

  swagger_path(:update) do
    path(@routes[:update])
    tag("Restaurants")
    produces("application/json")

    description("Updates a restaurant by ID.")
    parameter(:id, :path, :string, "Restaurant ID")
    parameter(:restaurant, :body, :Restaurant, "Restaurant data")
    response(200, "Restaurant resource", :Restaurant)
    response(404, "Not found")
    response(422, "Unprocessable entity", :Error)
  end

  def delete(conn, %{"id" => id}) do
    case RestaurantQueries.delete_restaurant(id) do
      {:ok, restaurant} ->
        conn
        |> put_status(:ok)
        |> json(restaurant)

      error ->
        error
    end
  end

  swagger_path(:delete) do
    path(@routes[:delete])
    tag("Restaurants")
    produces("application/json")

    description("Deletes a restaurant by ID.")
    parameter(:id, :path, :string, "Restaurant ID")
    response(200, "Restaurant resource", :Restaurant)
    response(404, "Not found")
  end

  def statistics(conn, %{"latitude" => lat, "longitude" => lng, "radius" => r}) do
    statistics = RestaurantQueries.get_nearest_restaurants(lat, lng, r)

    conn
    |> put_status(:ok)
    |> json(statistics)
  end

  def statistics(_conn, _params), do: {:error, :internal_server_error}

  swagger_path(:statistics) do
    path(@routes[:statistics])
    tag("Restaurants")
    produces("application/json")

    description("Returns statistics about the nearest restaurants.")
    parameter(:latitude, :query, :number, "Latitude")
    parameter(:longitude, :query, :number, "Longitude")
    parameter(:radius, :query, :integer, "Radius in meters")
    response(200, "Statistics", :RestaurantStatistics)
    response(500, "Internal server error")
  end

  # --- Swagger Definitions ----------------------------------------------------

  # coveralls-ignore-start
  def swagger_definitions,
    do: %{
      Restaurant:
        swagger_schema do
          title("Restaurant")
          description("Restaurant data.")

          properties do
            id(:string, "Restaurant ID", example: "123e4567-e89b-12d3-a456-426614174000")
            name(:string, "Restaurant name", example: "My Restaurant")
            site(:string, "Restaurant site", example: "https://myrestaurant.com")
            email(:string, "Restaurant email", example: "restaurant@mail.com")
            phone(:string, "Restaurant phone", example: "+1 234 567 890")
            street(:string, "Restaurant street", example: "1234 Main St")
            city(:string, "Restaurant city", example: "Springfield")
            state(:string, "Restaurant state", example: "IL")
            lat(:number, "Restaurant latitude", example: "39.781721")
            lng(:number, "Restaurant longitude", example: "-89.650148")
            inserted_at(:string, "Insertion timestamp", example: "2024-05-17T20:22:56Z")
            updated_at(:string, "Update timestamp", example: "2024-05-17T20:22:56Z")
          end
        end,
      RestaurantPage:
        swagger_schema do
          title("RestaurantPage")
          description("Restaurant page data.")

          properties do
            page(:integer, "Page number", example: 1)
            limit(:integer, "Page limit", example: 10)
            offset(:integer, "Page offset", example: 0)
            total_count(:integer, "Total number of restaurants", example: 100)
            count(:integer, "Number of restaurants in this page", example: 10)
            total_pages(:integer, "Total number of pages", example: 10)

            records(%Schema{
              type: :array,
              items: Schema.ref(:Restaurant)
            })
          end
        end,
      RestaurantStatistics:
        swagger_schema do
          title("RestaurantStatistics")
          description("Restaurant statistics data.")

          properties do
            count(:integer, "Number of restaurants", example: 10)
            avg(:number, "Average rating", example: 4.5)
            std(:number, "Rating standard deviation", example: 0.5)
          end
        end,
      Error:
        swagger_schema do
          title("Error")
          description("Error data.")

          example(%{
            errors: %{
              rating: [
                "invalid"
              ]
            }
          })
        end
    }
    # coveralls-ignore-stop
end
