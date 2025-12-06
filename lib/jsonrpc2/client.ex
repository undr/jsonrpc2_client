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

  alias JSONRPC2.Spec.Batch

  import Kernel, except: [send: 2]

  defdelegate call(method, params, id), to: Batch
  defdelegate call(batch, method, params, id), to: Batch
  defdelegate notify(method, params), to: Batch
  defdelegate notify(batch, method, params), to: Batch

  def send(%Batch{calls: calls, notifies: notifies}, url, opts \\ []) do
    adapter().execute(url, Map.values(calls) ++ notifies, opts)
  end

  def adapter do
    Application.get_env(
      :jsonrpc2_client,
      :adapter,
      JSONRPC2.Client.Adapters.Default
    )
  end
end
