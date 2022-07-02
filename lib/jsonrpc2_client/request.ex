defmodule JSONRPC2Client.Request do
  alias JSONRPC2Client.HTTP

  defstruct [calls: %{}, notifies: []]

  defguard is_id(value) when is_integer(value) or is_binary(value)
  defguard is_params(value) when is_map(value) or is_list(value)

  def new(method, params, id) when is_binary(method) and is_params(params) and is_id(id),
    do: %{jsonrpc: "2.0", id: id, method: method, params: params}
  def new(method, params)  when is_binary(method) and is_params(params),
    do: %{jsonrpc: "2.0", method: method, params: params}

  def notify(method, params),
    do: notify(%__MODULE__{}, method, params)
  def notify(%__MODULE__{notifies: notifies} = req, method, params) when is_binary(method) and is_params(params),
    do: %__MODULE__{req | notifies: notifies ++ [new(method, params)]}

  def call(method, params, id),
    do: call(%__MODULE__{}, method, params, id)
  def call(%__MODULE__{calls: calls} = req, method, params, id) when is_binary(method) and is_params(params) and is_id(id),
    do: %__MODULE__{req | calls: Map.put(calls, id, new(method, params, id))}

  def execute(%__MODULE__{calls: calls, notifies: notifies}, url, headers \\ %{}),
    do: HTTP.execute(url, Map.values(calls) ++ notifies, headers)
end
