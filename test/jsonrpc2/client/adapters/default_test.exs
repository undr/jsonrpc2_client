defmodule JSONRPC2.Client.Adapters.DefaultTest do
  use ExUnit.Case

  alias JSONRPC2.Client.Adapters.Default
  alias JSONRPC2.Spec.Request
  alias JSONRPC2.Spec.Result
  alias JSONRPC2.Spec.Error

  setup _ do
    {:ok, bypass: Bypass.open(port: 51346)}
  end

  describe ".execute" do
    test "success", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":1,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        assert Plug.Conn.get_req_header(conn, "x-key") == ["x-value"]
        Plug.Conn.resp(conn, 200, ~s<{"jsonrpc":"2.0","id":1,"result":"value"}>)
      end

      assert %Result{result: "value"} = Default.execute(
        "http://localhost:51346/jsonrpc",
        Request.new("method", [1, 2, 3], 1),
        [headers: %{"X-Key" => "x-value"}]
      )
    end

    test "404 status code", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":1,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 404, "")
      end

      assert %Error{error: %{code: -32000, data: %{code: 404}, message: "Server error"}} = Default.execute(
        "http://localhost:51346/jsonrpc", Request.new("method", [1, 2, 3], 1), []
      )
    end

    test "401 status code", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":1,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 401, "")
      end

      assert %Error{error: %{code: -32000, data: %{code: 401}, message: "Server error"}} = Default.execute(
        "http://localhost:51346/jsonrpc", Request.new("method", [1, 2, 3], 1), []
      )
    end

    test "500 status code", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":1,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 500, "")
      end

      assert %Error{error: %{code: -32000, data: %{code: 500}, message: "Server error"}} = Default.execute(
        "http://localhost:51346/jsonrpc", Request.new("method", [1, 2, 3], 1), []
      )
    end

    test "501 status code", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":1,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 501, "")
      end

      assert %Error{error: %{code: -32000, data: %{code: 501}, message: "Server error"}} = Default.execute(
        "http://localhost:51346/jsonrpc", Request.new("method", [1, 2, 3], 1), []
      )
    end
  end
end
