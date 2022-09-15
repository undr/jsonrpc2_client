defmodule JSONRPC2Client.Base do
  defmacro __using__(opts) do
    otp_app = Keyword.get(opts, :otp_app, false)

    quote location: :keep do
      alias JSONRPC2Client.Request
      alias JSONRPC2Client.Types, as: T

      @spec call(T.method(), T.params(), T.req_id()) :: T.request()
      def call(method, params, id),
        do: Request.call(method, params, id)

      @spec call(T.request(), T.method(), T.params(), T.req_id()) :: T.request()
      def call(req, method, params, id),
        do: Request.call(req, method, params, id)

      @spec notify(T.method(), T.params()) :: T.request()
      def notify(method, params),
        do: Request.notify(method, params)

      @spec notify(T.request(), T.method(), T.params()) :: T.request()
      def notify(req, method, params),
        do: Request.notify(req, method, params)

      @spec send(T.request(), T.url()) :: T.result()
      def send(req, url),
        do: Request.execute(%{req | adapter: adapter()}, url, [], [])

      @spec send(T.request(), T.url(), T.opts()) :: T.result()
      def send(req, url, opts) do
        {headers, opts} = Keyword.pop(opts, :headers)
        Request.execute(%{req | adapter: adapter()}, url, headers || [], opts)
      end

      @spec adapter() :: module()
      def adapter do
        if !unquote(otp_app) do
          raise(
            "Cannot find `JSONRPC2Client` adapter. You can fix it by either " <>
              "defining `otp_app` option when use `JSONRPC2Client.Base` module, " <>
              "or by overriding `adapter` fuction."
          )
        end

        Application.get_env(unquote(otp_app), __MODULE__)
      end

      defoverridable adapter: 0
    end
  end
end
