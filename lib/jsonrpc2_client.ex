defmodule JSONRPC2Client do
  @moduledoc """
  Documentation for `JSONRPC2Client`.

  Example:

      alias JSONRPC2Client.Response.Result
      alias JSONRPC2Client.Response.Error

      [%Result{}, %Error{}] = JSONRPC2Client.call(method, params, id)
      |> JSONRPC2Client.call(method, params, id)
      |> JSONRPC2Client.notify(method, params)
      |> JSONRPC2Client.send("http://127.0.0.1:4000")
  """

  defdelegate call(method, params, id), to: JSONRPC2Client.Request
  defdelegate call(req, method, params, id), to: JSONRPC2Client.Request

  defdelegate notify(method, params), to: JSONRPC2Client.Request
  defdelegate notify(req, method, params), to: JSONRPC2Client.Request

  defdelegate send(req, url), to: JSONRPC2Client.Request, as: :execute
  defdelegate send(req, url, headers), to: JSONRPC2Client.Request, as: :execute
end
