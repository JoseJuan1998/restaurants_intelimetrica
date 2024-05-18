defmodule RestaurantsWeb.SystemController do
  @moduledoc false

  use RestaurantsWeb, :controller

  # --- Development Information & Production Server health check ---------------

  def info(conn, params) do
    case Mix.env() do
      :dev ->
        conn
        |> put_status(200)
        |> json(app_info(params))
      _ ->
        conn
        |> put_status(200)
        |> json(%{status: "ok"})
    end
  end

  # Swagger Endpoint definition
  swagger_path :info do
    path(@routes[:info])
    tag("Info")
    produces("application/json")

    description("""
    Returns application information in develop environment. In staging and production environments works just as a server health check.
    """)

    parameter(:c, :query, :string, "Command")
    response(200, "Information resource", :Info)
  end

  # --- Documentation & Coverage report ----------------------------------------

  def code(conn, _params), do: safe_asset_redirect(conn, "/doc/code/index.html")

  def cover(conn, _params),
    do: safe_asset_redirect(conn, "/doc/cover/excoveralls.html")

  # ----------------------------------------------------------------------------

  # coveralls-ignore-start
  def swagger_definitions,
    do: %{
      Info:
        swagger_schema do
          title("App info")
          description("Application relative information.")

          properties do
            app(
              Schema.new do
                properties do
                  env(:string, "Environment", example: "dev")

                  service(
                    :string,
                    "Application name",
                    example: "restaurants"
                  )

                  version(
                    :string,
                    "Application version",
                    example: "0.0.0"
                  )
                end
              end
            )

            connections(
              Schema.new do
                properties do
                  databases(
                    Schema.new do
                      type(:array)

                      items(
                        Schema.new do
                          properties do
                            repo(
                              :string,
                              "Ecto repository name",
                              example: "#{Restaurants.Repo}"
                            )
                          end
                        end
                      )
                    end
                  )
                end
              end
            )
          end
        end
    }
    # coveralls-ignore-stop

  # === Private ================================================================

  defp app_info(%{} = params) do
    service = Mix.Project.config()[:app]
    version = Mix.Project.config()[:version]

    verbose =
      case params["c"] do
        "-v" -> true
        _ -> false
      end

    databases =
      service
      |> Application.get_env(:ecto_repos)
      |> Enum.map(fn repo ->
        [verbose, %{repo: repo}]
        |> case do
          [false, data] ->
            data

          [true, data] ->
            [version, time] =
              try do
                {:ok, %{rows: [[version]]}} =
                  apply(repo, :query, ["SELECT version();"])

                {:ok, %{rows: [[time]]}} =
                  apply(repo, :query, ["SELECT now();"])

                [version, time]
              rescue
                error -> [inspect(error), ""]
              end

            Map.merge(data, %{version: version, time: time})
        end
      end)

    app =
      [verbose, %{service: service, env: Mix.env(), version: version}]
      |> case do
        [false, data] ->
          data

        [true, data] ->
          time = NaiveDateTime.utc_now()

          [erlang, elixir] =
            try do
              {versions, 0} = System.cmd("elixir", ["-v"])

              versions
              |> String.split("\n")
              |> Enum.reject(fn e -> e == "" end)
            rescue
              error -> ["", inspect(error)]
            end

          data |> Map.merge(%{elixir: elixir, erlang: erlang, time: time})
      end

    %{
      app: app,
      connections: %{
        databases: databases
      }
    }
  end

  defp safe_asset_redirect(conn, path) do
    case File.exists?("priv/static#{path}") do
      false ->
        send_resp(conn, 404, "Not Found")

      true ->
        url = url(to: path)
        html = Plug.HTML.html_escape(url)
        body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

        conn
        |> put_resp_header("location", url)
        |> send_resp(conn.status || 302, "text/html", body)
    end
  end

  defp url(opts) do
    cond do
      to = opts[:to] -> validate_local_url(to)
      external = opts[:external] -> external
      true -> raise ArgumentError, "expected :to or :external option in redirect/2"
    end
  end

  @invalid_local_url_chars ["\\"]
  defp validate_local_url("//" <> _ = to), do: raise_invalid_url(to)

  defp validate_local_url("/" <> _ = to) do
    if String.contains?(to, @invalid_local_url_chars) do
      raise ArgumentError, "unsafe characters detected for local redirect in URL #{inspect(to)}"
    else
      to
    end
  end

  defp validate_local_url(to), do: raise_invalid_url(to)

  @spec raise_invalid_url(term()) :: no_return()
  defp raise_invalid_url(url) do
    raise ArgumentError, "the :to option in redirect expects a path but was #{inspect(url)}"
  end

  defp send_resp(conn, default_status, default_content_type, body) do
    conn
    |> ensure_resp_content_type(default_content_type)
    |> send_resp(conn.status || default_status, body)
  end

  defp ensure_resp_content_type(%Plug.Conn{resp_headers: resp_headers} = conn, content_type) do
    if List.keyfind(resp_headers, "content-type", 0) do
      conn
    else
      content_type = content_type <> "; charset=utf-8"
      %Plug.Conn{conn | resp_headers: [{"content-type", content_type} | resp_headers]}
    end
  end
end
