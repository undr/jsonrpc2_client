defmodule JSONRPC2Client.ResponseTest do
  use ExUnit.Case

  alias JSONRPC2Client.Response
  alias JSONRPC2Client.Response.Result
  alias JSONRPC2Client.Response.Error

  describe ".parse" do
    test "when response is JSON object" do
      assert %Result{id: "123", value: "value"} == Response.parse(~s[{"id":"123", "result":"value", "jsonrpc":"2.0"}])
      assert %Result{value: "value"} == Response.parse(~s[{"id":null, "result":"value", "jsonrpc":"2.0"}])
      assert %Result{value: "value"} == Response.parse(~s[{"result":"value", "jsonrpc":"2.0"}])

      assert %Error{id: "123", code: 321, message: "Msg"} == Response.parse(
        ~s[{"id":"123", "error":{"code":321, "message":"Msg"}, "jsonrpc":"2.0"}]
      )
      assert %Error{code: 321, message: "Msg"} == Response.parse(
        ~s[{"id":null, "error":{"code":321, "message":"Msg"}, "jsonrpc":"2.0"}]
      )
      assert %Error{code: 321, message: "Msg"} == Response.parse(
        ~s[{"error":{"code":321, "message":"Msg"}, "jsonrpc":"2.0"}]
      )

      assert %Error{id: "123", code: 321, message: "Msg", data: "data"} == Response.parse(
        ~s[{"id":"123", "error":{"code":321, "message":"Msg", "data":"data"}, "jsonrpc":"2.0"}]
      )
      assert %Error{code: 321, message: "Msg", data: "data"} == Response.parse(
        ~s[{"id":null, "error":{"code":321, "message":"Msg", "data":"data"}, "jsonrpc":"2.0"}]
      )
      assert %Error{code: 321, message: "Msg", data: "data"} == Response.parse(
        ~s[{"error":{"code":321, "message":"Msg", "data":"data"}, "jsonrpc":"2.0"}]
      )

      assert %Error{message: "Invalid Response", data: %{"id" => "123", "result" => "value"}} == Response.parse(
        ~s[{"id":"123", "result":"value"}]
      )

      response = ~s[{"id":"123", "result":"value]
      assert {:error, {:invalid_json_response, response}} == Response.parse(response)
    end

    test "when response is JSON array" do
      assert [%Result{id: "123", value: "value"}] == Response.parse(~s/[{"id":"123", "result":"value", "jsonrpc":"2.0"}]/)
      assert [%Result{value: "value"}] == Response.parse(~s/[{"id":null, "result":"value", "jsonrpc":"2.0"}]/)
      assert [%Result{value: "value"}] == Response.parse(~s/[{"result":"value", "jsonrpc":"2.0"}]/)

      assert [%Error{id: "123", code: 321, message: "Msg"}] == Response.parse(
        ~s/[{"id":"123", "error":{"code":321, "message":"Msg"}, "jsonrpc":"2.0"}]/
      )
      assert [%Result{value: "value"}, %Error{code: 321, message: "Msg"}] == Response.parse(
        ~s/[{"result":"value", "jsonrpc":"2.0"},{"id":null, "error":{"code":321, "message":"Msg"}, "jsonrpc":"2.0"}]/
      )

      assert [%Error{message: "Invalid Response", data: %{"id" => "123", "result" => "value"}}] == Response.parse(
        ~s/[{"id":"123", "result":"value"}]/
      )

      response = ~s/[{"id":"123", "result":"value]/
      assert {:error, {:invalid_json_response, response}} == Response.parse(response)
    end
  end
end
