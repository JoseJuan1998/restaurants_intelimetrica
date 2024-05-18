defmodule Restaurants.Repo.Migrations.CreateRestaurants do
  use Ecto.Migration

  def change do
    create table(:restaurants) do
      add :rating, :string
      add :name, :string
      add :site, :string
      add :email, :string
      add :phone, :string
      add :street, :string
      add :city, :string
      add :state, :string
      add :lat, :string
      add :lng, :string

      timestamps()
    end

    create unique_index(:restaurants, [:email])
    create unique_index(:restaurants, [:lat, :lng])
  end
end
