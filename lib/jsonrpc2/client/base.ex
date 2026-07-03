defmodule JSONRPC2.Client.Base do
  defmacro __using__(opts) do
    adapter = Keyword.get(opts, :adapter, JSONRPC2.Client.Adapters.Default)

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

        Telemetry.span(:client, meta, fn ->
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
