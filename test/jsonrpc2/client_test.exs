defmodule JSONRPC2.ClientTest do
  use ExUnit.Case

  alias JSONRPC2.Spec.Batch
  alias JSONRPC2.Spec.Request
  alias JSONRPC2.Spec.Result
  alias JSONRPC2.Client

  setup _ do
    {:ok, bypass: Bypass.open(port: 51346)}
  end

  test ".call and .notify" do
    assert %Batch{
      calls: %{1 => %Request{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]}}
    } == Client.call("add", [2, 5], 1)

    assert %Batch{
      notifies: [%Request{jsonrpc: "2.0", method: "add", params: [2, 5]}]
    } == Client.notify("add", [2, 5])

    assert %Batch{
      calls: %{
        1 => %Request{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]},
        2 => %Request{jsonrpc: "2.0", id: 2, method: "div", params: [8, 2]}
      },
      notifies: [%Request{jsonrpc: "2.0", method: "notify", params: %{name: "event1"}}]
    } == Client.call("add", [2, 5], 1) |> Client.call("div", [8, 2], 2) |> Client.notify("notify", %{name: "event1"})
  end

  describe ".send" do
    test "invocation request", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":1,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 200, ~s<{"jsonrpc":"2.0","id":1,"result":"value"}>)
      end

      req = Client.call("method", [1, 2, 3], 1)

      assert %Result{id: 1, result: "value"} == Client.send(req, "http://localhost:51346/jsonrpc")
    end

    test "notification request", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":null,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 200, ~s<>)
      end

      req = Client.notify("method", [1, 2, 3])

      assert [] == Client.send(req, "http://localhost:51346/jsonrpc")
    end
  end
end
