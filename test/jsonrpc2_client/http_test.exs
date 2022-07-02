defmodule JSONRPC2Client.HTTPTest do
  use ExUnit.Case

  alias JSONRPC2Client.HTTP
  alias JSONRPC2Client.Request
  alias JSONRPC2Client.Response

  setup _ do
    {:ok, bypass: Bypass.open(port: 51346)}
  end

  describe ".execute" do
    test "success", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"params":[1,2,3],"method":"method","jsonrpc":"2.0","id":1}>
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 200, ~s<{"jsonrpc":"2.0","id":1,"result":"value"}>)
      end

      assert %Response.Result{value: "value"} = HTTP.execute(
        "http://localhost:51346/jsonrpc", Request.new("method", [1, 2, 3], 1)
      )
    end

    test "404 status code", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"params":[1,2,3],"method":"method","jsonrpc":"2.0","id":1}>
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 404, "")
      end

      assert {:error, :not_found} = HTTP.execute(
        "http://localhost:51346/jsonrpc", Request.new("method", [1, 2, 3], 1)
      )
    end

    test "401 status code", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"params":[1,2,3],"method":"method","jsonrpc":"2.0","id":1}>
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 401, "")
      end

      assert {:error, :authentication_failed} = HTTP.execute(
        "http://localhost:51346/jsonrpc", Request.new("method", [1, 2, 3], 1)
      )
    end

    test "500 status code", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"params":[1,2,3],"method":"method","jsonrpc":"2.0","id":1}>
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 500, "")
      end

      assert {:error, :internal_server_error} = HTTP.execute(
        "http://localhost:51346/jsonrpc", Request.new("method", [1, 2, 3], 1)
      )
    end

    test "501 status code", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"params":[1,2,3],"method":"method","jsonrpc":"2.0","id":1}>
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 501, "")
      end

      assert {:error, {:server_error, 501}} = HTTP.execute(
        "http://localhost:51346/jsonrpc", Request.new("method", [1, 2, 3], 1)
      )
    end
  end
end
