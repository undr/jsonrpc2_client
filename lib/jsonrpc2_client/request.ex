defmodule JSONRPC2Client.Request do
  alias JSONRPC2Client.Adapters.HTTP
  alias JSONRPC2Client.Types, as: T

  @type t :: %__MODULE__{
    calls: map(),
    notifies: [map()],
    adapter: module() | nil
  }

  defstruct [calls: %{}, notifies: [], adapter: nil]

  defguard is_id(value) when is_integer(value) or is_binary(value)
  defguard is_params(value) when is_map(value) or is_list(value)

  @spec new(T.method(), T.params(), T.req_id()) :: map()
  def new(method, params, id) when is_binary(method) and is_params(params) and is_id(id),
    do: %{jsonrpc: "2.0", id: id, method: method, params: params}

  @spec new(T.method(), T.params()) :: map()
  def new(method, params)  when is_binary(method) and is_params(params),
    do: %{jsonrpc: "2.0", method: method, params: params}

  @spec notify(T.method(), T.params()) :: t()
  def notify(method, params),
    do: notify(%__MODULE__{}, method, params)

  @spec notify(t(), T.method(), T.params()) :: t()
  def notify(%__MODULE__{notifies: notifies} = req, method, params) when is_binary(method) and is_params(params),
    do: %__MODULE__{req | notifies: notifies ++ [new(method, params)]}

  @spec call(T.method(), T.params(), T.req_id()) :: t()
  def call(method, params, id),
    do: call(%__MODULE__{}, method, params, id)

  @spec call(t(), T.method(), T.params(), T.req_id()) :: t()
  def call(%__MODULE__{calls: calls} = req, method, params, id) when is_binary(method) and is_params(params) and is_id(id),
    do: %__MODULE__{req | calls: Map.put(calls, id, new(method, params, id))}

  @spec execute(t(), T.url(), T.headers(), T.opts()) :: T.result()
  def execute(%__MODULE__{calls: calls, notifies: notifies, adapter: adapter}, url, headers, opts) do
    (adapter || HTTP).execute(url, Map.values(calls) ++ notifies, headers, opts)
  end
end
