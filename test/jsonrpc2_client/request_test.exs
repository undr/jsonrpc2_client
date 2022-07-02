defmodule JSONRPC2Client.RequestTest do
  use ExUnit.Case

  alias JSONRPC2Client.Request

  test ".new" do
    assert %{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]} == Request.new("add", [2, 5], 1)
    assert %{jsonrpc: "2.0", id: 1, method: "add", params: %{v1: 2, v2: 5}} == Request.new("add", %{v1: 2, v2: 5}, 1)
    assert %{jsonrpc: "2.0", method: "add", params: [2, 5]} == Request.new("add", [2, 5])
    assert %{jsonrpc: "2.0", method: "add", params: %{v1: 2, v2: 5}} == Request.new("add", %{v1: 2, v2: 5})
  end

  test ".call and .notify" do
    assert %Request{calls: %{1 => %{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]}}} == Request.call("add", [2, 5], 1)
    assert %Request{
      calls: %{
        1 => %{jsonrpc: "2.0", id: 1, method: "add", params: [2, 5]},
        2 => %{jsonrpc: "2.0", id: 2, method: "div", params: [8, 2]}
      },
      notifies: [%{jsonrpc: "2.0", method: "notify", params: %{name: "event1"}}]
    } == Request.call("add", [2, 5], 1) |> Request.call("div", [8, 2], 2) |> Request.notify("notify", %{name: "event1"})
  end
end
