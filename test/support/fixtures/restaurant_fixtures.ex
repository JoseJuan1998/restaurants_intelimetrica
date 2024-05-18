defmodule Restaurants.RestaurantFixtures do
  import Restaurants.Factory

  def restaurants_fixture(_attrs \\ %{}) do
    %{
      restaurant_0: insert(:restaurant),
      restaurant_1: insert(:restaurant),
      restaurant_2: insert(:restaurant),
      restaurant_3: insert(:restaurant),
      restaurant_4: insert(:restaurant)
    }
  end
end
