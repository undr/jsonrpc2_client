defmodule JSONRPC2Client do
  @moduledoc """
  Documentation for `JSONRPC2Client`.

  Example:
      alias JSONRPC2Client.Response.Result
      alias JSONRPC2Client.Response.Error

      [%Result{}, %Error{}] =
        method
        |> JSONRPC2Client.call(params, id)
        |> JSONRPC2Client.call(method, params, id)
        |> JSONRPC2Client.notify(method, params)
        |> JSONRPC2Client.send(
          "http://127.0.0.1:4000",
          headers: [%{"X-Token" => token()}],
          recv_timeout: 3000,
          timeout: 3000
        )
  """
  use JSONRPC2Client.Base

  def adapter do
    JSONRPC2Client.Adapters.HTTP
  end
end
