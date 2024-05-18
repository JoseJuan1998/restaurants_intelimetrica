defmodule RestaurantsWeb.Router do
  use RestaurantsWeb, :router

  pipeline :api, do: plug(:accepts, ["json"])

  pipeline :assets, do: plug(:accepts, ["html"])

  scope "/", RestaurantsWeb do
    pipe_through :api

    get "/", SystemController, :info
  end

  scope "/api", RestaurantsWeb do
    pipe_through :api

    get "/restaurants", RestaurantsController, :page
    get "/restaurants/:id", RestaurantsController, :get
    post "/restaurants", RestaurantsController, :create
    patch "/restaurants/:id", RestaurantsController, :update
    delete "/restaurants/:id", RestaurantsController, :delete
  end

  scope "/restaurants", RestaurantsWeb do
    pipe_through :api

    get "/statistics", RestaurantsController, :statistics
  end

  # ----------------------------------------------------------------------------
  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]

      # If you want to use the LiveDashboard in production, you should put
      # it behind authentication and allow only admins to access it.
      # If your application does not have an admins-only section yet,
      # you can use Plug.BasicAuth to set up some basic authentication
      # as long as you are also using SSL (which you should anyway).
      live_dashboard "/dashboard", metrics: RestaurantsWeb.Telemetry
    end

    scope "/doc" do
      pipe_through :assets

      get "/code", RestaurantsWeb.SystemController, :code
      get "/coverage", RestaurantsWeb.SystemController, :cover
    end
  end

  # Enables the automated tests coverage report.
  # Enables the Swoosh mailbox preview in development.
  if Mix.env() == :dev do
    scope "/doc" do
      forward "/api",
              PhoenixSwagger.Plug.SwaggerUI,
              otp_app: :restaurants,
              swagger_file: "swagger.json"
    end
  end

  # Configuration for the Swagger API-REST documentation generator.
  def swagger_info,
    do: %{
      swagger: "2.0",
      info: %{
        title: "Restaurants",
        version: Mix.Project.config()[:version],
        description:
          "Welcome to the API documentation for the Restaurants Project. This comprehensive guide provides detailed information on how to interact with this RESTful API endpoints."
      },
      host: "#{System.get_env("HOST")}:#{System.get_env("PORT")}"
    }
end
