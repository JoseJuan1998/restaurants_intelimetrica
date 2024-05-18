defmodule RestaurantsWeb.RestaurantsControllerTest do
  use RestaurantsWeb.ConnCase

  alias Restaurants.Restaurant
  alias Restaurants.Repo

  import Restaurants.RestaurantFixtures

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "GET api/restaurants" do
    setup [:restaurants_fixture]

    @tag :restaurants
    test "list a paginated list of restaurants", %{conn: conn} do
      response =
        conn
        |> get(Routes.restaurants_path(conn, :page, %{}))
        |> json_response(200)

      assert %{
               "count" => 5,
               "limit" => 10,
               "offset" => 0,
               "page" => 1,
               "records" => records,
               "search" => nil,
               "total_count" => 5,
               "total_pages" => 1
             } = response

      assert Enum.count(records) === 5
    end

    @tag :restaurants
    test "swagger endpoint definition" do
      response = RestaurantsWeb.RestaurantsController.swagger_path_page([])

      assert %{
               "/api/restaurants" => %{
                 "get" => %{}
               }
             } = response
    end
  end

  describe "GET api/restaurants/:id" do
    setup [:restaurants_fixture]

    @tag :restaurants
    test "gets one restaurant by id", %{conn: conn, restaurant_0: %{id: id}} do
      response =
        conn
        |> get(Routes.restaurants_path(conn, :get, id))
        |> json_response(200)

      assert %{
               "city" => _,
               "email" => _,
               "id" => ^id,
               "lat" => _,
               "lng" => _,
               "name" => _,
               "phone" => _,
               "rating" => _,
               "site" => _,
               "state" => _
             } = response
    end

    @tag :restaurants
    test "gets not found when restaurant does not exist", %{conn: conn} do
      response =
        conn
        |> get(Routes.restaurants_path(conn, :get, Ecto.UUID.generate()))
        |> json_response(404)

      assert %{"errors" => %{"detail" => "Not Found"}} = response
    end

    @tag :restaurants
    test "swagger endpoint definition" do
      response = RestaurantsWeb.RestaurantsController.swagger_path_get([])

      assert %{
               "/api/restaurants/{id}" => %{
                 "get" => %{}
               }
             } = response
    end
  end

  describe "POST api/restaurants" do
    setup [:restaurants_fixture]

    @tag :restaurants
    test "creates a restaurant", %{conn: conn} do
      params = params_for(:restaurant)

      response =
        conn
        |> post(Routes.restaurants_path(conn, :create), %{restaurant: params})
        |> json_response(201)

      assert params.name === response["name"]
      assert params.site === response["site"]
      assert params.email === response["email"]
      assert params.phone === response["phone"]
      assert params.street === response["street"]
      assert params.city === response["city"]
      assert params.state === response["state"]
      assert params.lat === response["lat"]
      assert params.lng === response["lng"]
    end

    @tag :restaurants
    test "swagger endpoint definition" do
      response = RestaurantsWeb.RestaurantsController.swagger_path_create([])

      assert %{
               "/api/restaurants" => %{
                 "post" => %{}
               }
             } = response
    end
  end

  describe "PATCH api/restaurants/:id" do
    setup [:restaurants_fixture]

    @tag :restaurants
    test "updates a restaurant", %{conn: conn, restaurant_0: %{id: id}} do
      params = %{name: "Updated Name"}

      response =
        conn
        |> patch(Routes.restaurants_path(conn, :update, id), %{restaurant: params})
        |> json_response(200)

      assert params.name === response["name"]
    end

    @tag :restaurants
    test "gets not found when restaurant does not exist", %{conn: conn} do
      response =
        conn
        |> patch(Routes.restaurants_path(conn, :update, Ecto.UUID.generate()), %{restaurant: %{}})
        |> json_response(404)

      assert %{"errors" => %{"detail" => "Not Found"}} = response
    end

    @tag :restaurants
    test "gets error when invalid params", %{conn: conn, restaurant_0: %{id: id}} do
      response =
        conn
        |> patch(Routes.restaurants_path(conn, :update, id), %{restaurant: %{lng: %{}}})
        |> json_response(422)

      assert %{"errors" => _} = response
    end

    @tag :restaurants
    test "swagger endpoint definition" do
      response = RestaurantsWeb.RestaurantsController.swagger_path_update([])

      assert %{
               "/api/restaurants/{id}" => %{
                 "patch" => %{}
               }
             } = response
    end
  end

  describe "DELETE api/restaurants/:id" do
    setup [:restaurants_fixture]

    @tag :restaurants
    test "deletes a restaurant", %{conn: conn, restaurant_0: %{id: id}} do
      response =
        conn
        |> delete(Routes.restaurants_path(conn, :delete, id))
        |> json_response(200)

      assert %{
               "city" => _,
               "email" => _,
               "id" => ^id,
               "lat" => _,
               "lng" => _,
               "name" => _,
               "phone" => _,
               "rating" => _,
               "site" => _,
               "state" => _
             } = response

      assert Repo.get(Restaurant, id) === nil
    end

    @tag :restaurants
    test "gets not found when restaurant does not exist", %{conn: conn} do
      response =
        conn
        |> delete(Routes.restaurants_path(conn, :delete, Ecto.UUID.generate()))
        |> json_response(404)

      assert %{"errors" => %{"detail" => "Not Found"}} = response
    end

    @tag :restaurants
    test "swagger endpoint definition" do
      response = RestaurantsWeb.RestaurantsController.swagger_path_delete([])

      assert %{
               "/api/restaurants/{id}" => %{
                 "delete" => %{}
               }
             } = response
    end
  end

  describe "GET api/restaurants/statistics" do
    setup [:restaurants_fixture]

    @tag :restaurants
    test "gets nearest restaurants", %{conn: conn, restaurant_0: %{lat: lat, lng: lng, rating: rating}} do
      response =
        conn
        |> get(Routes.restaurants_path(conn, :statistics),
          latitude: lat,
          longitude: lng,
          radius: 1000
        )
        |> json_response(200)

      assert String.to_float(rating <> ".0") === response["avg"]
      assert 1 === response["count"]
      assert nil === response["std"]
    end

    @tag :restaurants
    test "gets empty nearest restaurants", %{conn: conn} do
      response =
        conn
        |> get(Routes.restaurants_path(conn, :statistics),
          latitude: 0.0,
          longitude: 0.0,
          radius: 1000
        )
        |> json_response(200)

      assert %{"avg" => nil, "count" => 0, "std" => nil} = response
    end

    @tag :restaurants
    test "swagger endpoint definition" do
      response = RestaurantsWeb.RestaurantsController.swagger_path_statistics([])

      assert %{
               "/restaurants/statistics" => %{
                 "get" => %{}
               }
             } = response
    end
  end
end
