defmodule JSONRPC2Client.Types do
  alias JSONRPC2Client.Request
  alias JSONRPC2Client.Response.Result
  alias JSONRPC2Client.Response.Error

  @type response :: Error.t() | Result.t()
  @type request :: Request.t()
  @type method :: String.t()
  @type params :: list() | map()
  @type req_id :: String.t() | integer()
  @type ok :: {:ok, response()} | {:ok, [response()]}
  @type error :: {:error, {atom(), map()}}
  @type result :: ok() | error()
  @type url :: HTTPoison.url()
  @type opts :: HTTPoison.options()
  @type headers :: HTTPoison.headers()
  @type raw_data :: [map()] | map()
end
