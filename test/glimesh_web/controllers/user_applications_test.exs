defmodule GlimeshWeb.UserApplicationsTest do
  use GlimeshWeb.ConnCase

  alias Glimesh.Apps
  import Glimesh.AccountsFixtures

  setup :register_and_log_in_user

  @create_attrs %{
    name: "some name",
    description: "some description",
    homepage_url: "https://glimesh.tv/",
    oauth_application: %{
      redirect_uri: "https://glimesh.tv/something"
    }
  }
  @update_attrs %{
    name: "some updated name",
    description: "some updated description",
    homepage_url: "https://dev.glimesh.tv/",
    oauth_application: %{
      redirect_uri: "https://glimesh.tv/something-new"
    }
  }
  @invalid_attrs %{
    name: nil,
    description: nil,
    oauth_application: %{
      redirect_uri: nil
    }
  }

  def fixture(:app) do
    {:ok, app} = Apps.create_app(user_fixture(), @create_attrs)
    app
  end

  describe "index" do
    test "lists all apps", %{conn: conn} do
      conn = get(conn, Routes.user_applications_path(conn, :index))
      assert html_response(conn, 200) =~ "Applications"
    end
  end

  describe "new app" do
    setup :register_and_log_in_admin_user

    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_applications_path(conn, :new))
      assert html_response(conn, 200) =~ "Create Application"
    end
  end

  describe "create app" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_applications_path(conn, :create), app: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_applications_path(conn, :show, id)

      conn = get(conn, Routes.user_applications_path(conn, :show, id))
      assert html_response(conn, 200) =~ "some name"
      assert html_response(conn, 200) =~ "https://glimesh.tv/something"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_applications_path(conn, :create), app: @invalid_attrs)
      assert html_response(conn, 200) =~ "Create Application"
    end
  end

  describe "edit app" do
    setup [:create_app]

    test "renders form for editing chosen app", %{conn: conn, app: app} do
      conn = get(conn, Routes.user_applications_path(conn, :edit, app.id))
      assert html_response(conn, 200) =~ "Edit Application"
    end
  end

  describe "update app" do
    setup [:create_app]

    test "redirects when data is valid", %{conn: conn, app: app} do
      conn = put(conn, Routes.user_applications_path(conn, :update, app), app: @update_attrs)

      assert redirected_to(conn) == Routes.user_applications_path(conn, :show, app)

      conn = get(conn, Routes.user_applications_path(conn, :show, app))
      assert html_response(conn, 200) =~ "some updated name"
      assert html_response(conn, 200) =~ app.oauth_application.secret
    end

    test "renders errors when data is invalid", %{conn: conn, app: app} do
      conn = put(conn, Routes.user_applications_path(conn, :update, app), app: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit Application"
    end
  end

  defp create_app(_) do
    app = fixture(:app)
    %{app: app}
  end
end
