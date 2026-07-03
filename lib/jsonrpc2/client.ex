defmodule JSONRPC2.Client do
  @moduledoc """
  Documentation for `JSONRPC2.Client`.

  Example:
      alias JSONRPC2.Spec.Result
      alias JSONRPC2.Spec.Error

      [%Result{}, %Error{}] =
        method
        |> JSONRPC2.Client.call(params, id)
        |> JSONRPC2.Client.call(method, params, id)
        |> JSONRPC2.Client.notify(method, params)
        |> JSONRPC2.Client.send(
          "http://127.0.0.1:4000",
          headers: [%{"X-Token" => token()}],
          recv_timeout: 3000,
          timeout: 3000
        )
  """

  use JSONRPC2.Client.Base
end
