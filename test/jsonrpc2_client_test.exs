defmodule JSONRPC2ClientTest do
  use ExUnit.Case

  alias JSONRPC2Client.Request
  alias JSONRPC2Client.Response

  setup _ do
    {:ok, bypass: Bypass.open(port: 51346)}
  end

  test ".call and .notify" do
    assert %Request{
      calls: %{1 => %{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]}}
    } == JSONRPC2Client.call("add", [2, 5], 1)

    assert %Request{
      notifies: [%{jsonrpc: "2.0", method: "add", params: [2, 5]}]
    } == JSONRPC2Client.notify("add", [2, 5])

    assert %Request{
      calls: %{
        1 => %{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]},
        2 => %{jsonrpc: "2.0", id: 2, method: "div", params: [8, 2]}
      },
      notifies: [%{jsonrpc: "2.0", method: "notify", params: %{name: "event1"}}]
    } == Request.call("add", [2, 5], 1)
    |> Request.call("div", [8, 2], 2)
    |> JSONRPC2Client.notify("notify", %{name: "event1"})
  end

  describe ".send" do
    test "invocation request", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"params":[1,2,3],"method":"method","jsonrpc":"2.0","id":1}>
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 200, ~s<{"jsonrpc":"2.0","id":1,"result":"value"}>)
      end

      req = JSONRPC2Client.call("method", [1, 2, 3], 1)

      assert %Response.Result{id: 1, value: "value"} == JSONRPC2Client.send(req, "http://localhost:51346/jsonrpc")
    end

    test "notification request", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == ~s<{"params":[1,2,3],"method":"method","jsonrpc":"2.0"}>
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 200, ~s<>)
      end

      req = JSONRPC2Client.notify("method", [1, 2, 3])

      assert [] == JSONRPC2Client.send(req, "http://localhost:51346/jsonrpc")
    end
  end
end
