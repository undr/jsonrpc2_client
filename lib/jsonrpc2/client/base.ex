defmodule JSONRPC2.Client.Base do
  @moduledoc """
  Base of a JSON-RPC client.

  Options:

    * `:adapter` — the module that executes a request, `JSONRPC2.Client.Adapters.Default` by
      default.
    * `:telemetry` — the namespace the emitted events begin with, `:jsonrpc2` by default. A
      client declaring `telemetry: :wallet` emits `[:wallet, :client, :start]` and so on.

  The namespace exists because a `:telemetry` handler subscribes to an event NAME and to nothing
  else: while two clients share a name, every handler attached to it receives both clients'
  events and cannot tell which is which, whatever it inspects. A host that talks to more than one
  upstream gives each client its own namespace, or it can only report on all of them at once.
  """

  defmacro __using__(opts) do
    adapter = Keyword.get(opts, :adapter, JSONRPC2.Client.Adapters.Default)
    telemetry = Keyword.get(opts, :telemetry, :jsonrpc2)

    quote location: :keep do
      alias JSONRPC2.Telemetry
      alias JSONRPC2.Spec.Batch

      import Kernel, except: [send: 2]

      defdelegate call(method, params, id),
        to: Batch

      defdelegate call(batch, method, params, id),
        to: Batch

      defdelegate notify(method, params),
        to: Batch

      defdelegate notify(batch, method, params),
        to: Batch

      def send(%Batch{calls: calls, notifies: notifies}, url, opts \\ []) do
        calls_n_notifies = Map.values(calls) ++ notifies
        meta =
          %{
            batch: calls_n_notifies,
            url: url,
            opts: opts
          }

        Telemetry.span(unquote(telemetry), :client, meta, fn ->
          res = adapter().execute(url, calls_n_notifies, opts)
          {res, Map.merge(meta, %{res: res})}
        end)
      end

      def adapter do
        unquote(adapter)
      end

      defoverridable adapter: 0
    end
  end
end
