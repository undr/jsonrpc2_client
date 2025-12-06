defmodule JSONRPC2.Client.Adapters.Behaviour do
  alias JSONRPC2.Spec.Error
  alias JSONRPC2.Spec.Result

  @callback execute(String.t() | URI.t(), [map()], keyword()) :: Result.t() |  Error.t()
end
