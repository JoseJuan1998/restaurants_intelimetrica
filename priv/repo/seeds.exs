# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Restaurants.Repo.insert!(%Restaurants.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Restaurants.Repo
alias Restaurants.Restaurant

defmodule Data do
  def setup do
    headers = ~w(id rating name site email phone street city state lat lng)a

    if Repo.all(Restaurant) == [] do
      restaurants_data =
        "./restaurants.csv"
        |> Path.expand(__DIR__)
        |> File.stream!()
        |> Stream.drop(1)
        |> Stream.map(&String.trim(&1, "\n"))
        |> Stream.map(&String.split(&1, ~r/,(?! )/))
        |> Enum.take(100)
        |> Enum.reduce([], fn row, acc ->
          map =
            headers
            |> Enum.zip(row)
            |> Enum.into(%{})
            |> Map.put(:inserted_at, DateTime.utc_now())
            |> Map.put(:updated_at, DateTime.utc_now())

          acc ++ [map]
        end)

      Repo.insert_all(Restaurant, restaurants_data)
    else
      nil
    end
  end
end


Data.setup()
