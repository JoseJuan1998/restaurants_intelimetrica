defmodule Restaurants.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: Restaurants.Repo

  def restaurant_factory do
    %Restaurants.Restaurant{
      rating: 1..5 |> Enum.random() |> to_string(),
      name: sequence("Test Restaurant "),
      site: sequence("https://www.testrestaurant") <> ".com",
      email: sequence("test_email_") <> "@test.com",
      phone: "5555555555",
      street: sequence("Street "),
      city: sequence("City "),
      state: "CDMX",
      lat: random_lat(),
      lng: random_lng()
    }
  end

  defp random_lat do
    min = -90.0
    max = 90.0
    :rand.uniform() * (max - min) + min
    |> to_string()
  end

  defp random_lng do
    min = -180.0
    max = 180.0
    :rand.uniform() * (max - min) + min
    |> to_string()
  end
end
