defmodule Restaurants.Restaurant do
  use Restaurants.Schema

  @derive {Jason.Encoder, except: [:__meta__]}
  @primary_key {:id, Ecto.UUID, autogenerate: true}
  schema "restaurants" do
    field :rating, :string
    field :name, :string
    field :site, :string
    field :email, :string
    field :phone, :string
    field :street, :string
    field :city, :string
    field :state, :string
    field :lat, :string
    field :lng, :string

    timestamps()
  end

  @fields ~w(rating name site email phone street city state lat lng)a

  @spec changeset(t, map) :: Ecto.Changeset.t()
  def changeset(restaurant, attrs) do
    restaurant
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
