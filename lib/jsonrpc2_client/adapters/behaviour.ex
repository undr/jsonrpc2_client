defmodule JSONRPC2Client.Adapters.Behaviour do
  alias JSONRPC2Client.Types, as: T

  @callback execute(T.url(), T.raw_data(), T.headers(), T.opts()) :: T.result()
end

