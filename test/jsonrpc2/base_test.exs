defmodule JSONRPC2.Client.BaseTest do
  use ExUnit.Case


  defmodule Client1 do
    use JSONRPC2.Client.Base,
      adapter: JSONRPC2.Client.Adapters.Default
  end

  defmodule Client2 do
    use JSONRPC2.Client.Base

    def adapter do
      JSONRPC2.Client.Adapters.Default
    end
  end

  defmodule NamespacedClient do
    use JSONRPC2.Client.Base,
      telemetry: :wallet
  end

  alias JSONRPC2.Spec.Batch
  alias JSONRPC2.Spec.Request
  alias JSONRPC2.Spec.Result

  setup _ do
    {:ok, bypass: Bypass.open(port: 51346)}
  end

  test ".call and .notify" do
    assert %Batch{
      calls: %{1 => %Request{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]}}
    } == Client1.call("add", [2, 5], 1)

    assert %Batch{
      notifies: [%Request{jsonrpc: "2.0", method: "add", params: [2, 5]}]
    } == Client1.notify("add", [2, 5])

    assert %Batch{
      calls: %{
        1 => %Request{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]},
        2 => %Request{jsonrpc: "2.0", id: 2, method: "div", params: [8, 2]}
      },
      notifies: [%Request{jsonrpc: "2.0", method: "notify", params: %{name: "event1"}}]
    } == Client1.call("add", [2, 5], 1) |> Client1.call("div", [8, 2], 2) |> Client1.notify("notify", %{name: "event1"})

    assert %Batch{
      calls: %{1 => %Request{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]}}
    } == Client2.call("add", [2, 5], 1)

    assert %Batch{
      notifies: [%Request{jsonrpc: "2.0", method: "add", params: [2, 5]}]
    } == Client2.notify("add", [2, 5])

    assert %Batch{
      calls: %{
        1 => %Request{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]},
        2 => %Request{jsonrpc: "2.0", id: 2, method: "div", params: [8, 2]}
      },
      notifies: [%Request{jsonrpc: "2.0", method: "notify", params: %{name: "event1"}}]
    } == Client2.call("add", [2, 5], 1) |> Client2.call("div", [8, 2], 2) |> Client2.notify("notify", %{name: "event1"})
  end

  describe ".send" do
    test "invocation request", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":1,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 200, ~s<{"jsonrpc":"2.0","id":1,"result":"value"}>)
      end

      req = Client1.call("method", [1, 2, 3], 1)

      assert %Result{id: 1, result: "value"} == Client1.send(req, "http://localhost:51346/jsonrpc")

      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":1,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 200, ~s<{"jsonrpc":"2.0","id":1,"result":"value"}>)
      end

      req = Client2.call("method", [1, 2, 3], 1)

      assert %Result{id: 1, result: "value"} == Client2.send(req, "http://localhost:51346/jsonrpc")
    end

    test "notification request", %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":null,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 200, ~s<>)
      end

      req = Client1.notify("method", [1, 2, 3])

      assert [] == Client1.send(req, "http://localhost:51346/jsonrpc")

      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        {:ok, body, conn} = Plug.Conn.read_body(conn)
        assert body == "{\"id\":null,\"method\":\"method\",\"params\":[1,2,3],\"jsonrpc\":\"2.0\"}"
        assert Plug.Conn.get_req_header(conn, "content-type") == ["application/json"]
        Plug.Conn.resp(conn, 200, ~s<>)
      end

      req = Client2.notify("method", [1, 2, 3])

      assert [] == Client2.send(req, "http://localhost:51346/jsonrpc")
    end
  end

  # A :telemetry handler subscribes to an event NAME and to nothing else, so two clients sharing
  # one name are indistinguishable to every handler attached to it. These two prove a host can
  # give each client a name of its own — and that a client which asks for nothing keeps the name
  # the library emitted before the option existed.
  describe "telemetry namespace" do
    setup %{bypass: bypass} do
      Bypass.expect bypass, "POST", "/jsonrpc", fn conn ->
        Plug.Conn.resp(conn, 200, ~s<{"jsonrpc":"2.0","id":1,"result":"value"}>)
      end

      :telemetry.attach_many(
        "client-telemetry-test",
        [
          [:jsonrpc2, :client, :start],
          [:jsonrpc2, :client, :stop],
          [:wallet, :client, :start],
          [:wallet, :client, :stop]
        ],
        fn event, _measurements, _meta, pid -> send(pid, {:event, event}) end,
        self()
      )

      on_exit(fn -> :telemetry.detach("client-telemetry-test") end)
    end

    test "a client without the option emits under :jsonrpc2" do
      "method" |> Client1.call([1, 2, 3], 1) |> Client1.send("http://localhost:51346/jsonrpc")

      assert_received {:event, [:jsonrpc2, :client, :start]}
      assert_received {:event, [:jsonrpc2, :client, :stop]}
      refute_received {:event, [:wallet, :client, :start]}
    end

    test "a client with the option emits under its own namespace" do
      "method"
      |> NamespacedClient.call([1, 2, 3], 1)
      |> NamespacedClient.send("http://localhost:51346/jsonrpc")

      assert_received {:event, [:wallet, :client, :start]}
      assert_received {:event, [:wallet, :client, :stop]}
      refute_received {:event, [:jsonrpc2, :client, :start]}
    end
  end
end
