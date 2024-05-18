defmodule RestaurantsWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use RestaurantsWeb, :controller
      use RestaurantsWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: RestaurantsWeb
      use PhoenixSwagger

      import Plug.Conn

      alias PhoenixSwagger.Path
      alias RestaurantsWeb.Router.Helpers, as: Routes

      @routes RestaurantsWeb.Router.__routes__()
              |> Enum.filter(fn route -> route.plug == __MODULE__ end)
              |> Enum.map(fn route ->
                path =
                  route.path
                  |> String.split("/")
                  |> Enum.map_join("/", fn e ->
                    case String.starts_with?(e, ":") do
                      true -> "{#{String.slice(e, 1..-1)}}"
                      false -> e
                    end
                  end)

                {route.plug_opts, %{route | path: path}}
              end)

      def path(path_object, route) do
        case route.verb do
          :options -> Path.options(path_object, route.path)
          :head -> Path.head(path_object, route.path)
          :get -> Path.get(path_object, route.path)
          :post -> Path.post(path_object, route.path)
          :put -> Path.put(path_object, route.path)
          :patch -> Path.patch(path_object, route.path)
          :delete -> Path.delete(path_object, route.path)
        end
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
