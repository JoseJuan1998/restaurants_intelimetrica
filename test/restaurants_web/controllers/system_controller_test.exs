defmodule RestaurantsWeb.SystemControllerTest do
  use RestaurantsWeb.ConnCase

  import Mock

  describe "[ctrl] info" do
    alias Restaurants.Repo

    @tag :controller
    test "returns empty response", %{conn: conn} do
      response =
        conn
        |> get(Routes.system_path(conn, :info))
        |> json_response(200)

      assert %{} = response
    end

    @tag :controller
    test "returns application information in dev", %{conn: conn} do
      with_mock Mix, [:passthrough], env: fn -> :dev end do
        response =
          conn
          |> get(Routes.system_path(conn, :info))
          |> json_response(200)

        assert %{} = response
      end
    end

    @tag :controller
    test "returns application more verbose information in dev", %{conn: conn} do
      with_mock Mix, [:passthrough], env: fn -> :dev end do
        response =
          conn
          |> get(Routes.system_path(conn, :info, %{c: "-v"}))
          |> json_response(200)

        assert %{} = response
      end
    end

    @tag :controller
    test "handle broker connection errors", %{conn: conn} do
      with_mocks [
        {Mix, [:passthrough], env: fn -> :dev end}
      ] do
        response =
          conn
          |> get(Routes.system_path(conn, :info, %{c: "-v"}))
          |> json_response(200)

        assert %{} = response
      end
    end

    @tag :controller
    test "handle repos errors", %{conn: conn} do
      with_mocks [
        {Mix, [:passthrough], env: fn -> :dev end},
        {Repo, [:passthrough], query: fn _ -> raise RuntimeError end}
      ] do
        response =
          conn
          |> get(Routes.system_path(conn, :info, %{c: "-v"}))
          |> json_response(200)

        assert %{} = response
      end
    end

    @tag :controller
    test "handle system command errors", %{conn: conn} do
      with_mocks [
        {Mix, [:passthrough], env: fn -> :dev end},
        {System, [:passthrough], cmd: fn _, _ -> raise RuntimeError end}
      ] do
        response =
          conn
          |> get(Routes.system_path(conn, :info, %{c: "-v"}))
          |> json_response(200)

        assert %{} = response
      end
    end

    @tag :controller
    test "swagger endpoint definition" do
      response = RestaurantsWeb.SystemController.swagger_path_info([])

      assert %{"/" => %{"get" => %{}}} = response
    end
  end

  describe "[ctrl] code" do
    @tag :controller
    test "return HTML formated code documentation", %{conn: conn} do
      status = create_file("priv/static/doc/code", "index.html")

      response =
        conn
        |> get(Routes.system_path(conn, :code))
        |> html_response(302)

      if status == :created, do: File.rm!("priv/static/doc/code/index.html")

      assert response =~ "redirected"
    end
  end

  describe "[ctrl] cover" do
    @tag :controller
    test "return HTML formated coverage report", %{conn: conn} do
      status = create_file("priv/static/doc/cover", "excoveralls.html")

      response =
        conn
        |> get(Routes.system_path(conn, :cover))
        |> html_response(302)

      if status == :created,
        do: File.rm!("priv/static/doc/cover/excoveralls.html")

      assert response =~ "redirected"
    end
  end

  describe "[ctrl] info schema definitions" do
    @tag :controller
    test "swagger schema definitions" do
      response = RestaurantsWeb.SystemController.swagger_definitions()

      assert %{Info: %{}} = response
    end
  end

  # === Private ================================================================

  defp create_file(path, file, content \\ "") do
    path_list = String.split(path, "/")

    Enum.each(path_list, fn e ->
      File.mkdir(e)
      File.cd!(e)
    end)

    file_status =
      case File.exists?(file) do
        true ->
          :exists

        false ->
          File.write!(file, content)
          :created
      end

    Enum.each(path_list, fn _ -> File.cd!("..") end)
    file_status
  end
end
