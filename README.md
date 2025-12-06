# JSONRPC2.Client

HTTP client for JSONRPC 2.0 protocol.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `jsonrpc2_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jsonrpc2_client, "~> 2.0.0"}
  ]
end
```

## Configuration

The library provides with default `JSONRPC2.Client.Adapters.Default` adapter. Nonetheless, it's possible to use custom adapter. It can be any module which implements `JSONRPC2.Client.Adapters.Behaviour` behaviour. For example, it can be adapter built by `mox` library, to make easy to test application what using this library. 

```elixir
config :jsonrpc2_client, :adapter, MyClient.MyAdapter
```

```elixir
defmodule MyClient.MyAdapter do
  @behaviour JSONRPC2.Client.Adapters.Behaviour

  def execute(url, data, opts) do
    # ...
  end
end
```

## Usage

First, we collect operations and then send it in one single batch into the server.

```elixir
alias JSONRPC2.Spec.Result
alias JSONRPC2.Spec.Error

[%Result{}, %Error{}] =
  JSONRPC2.Client.call("add", [100, 120], 1)
  |> JSONRPC2.Client.call("div", [120, 0], 2)
  |> JSONRPC2.Client.notify("send_event", ["user.action", %{payload: "payload"}])
  |> JSONRPC2.Client.send("http://127.0.0.1:4000")
```

## Testing

```elixir
Mox.defmock(MyClient.MockAdapter, for: JSONRPC2.Client.Adapters.Behaviour)
Application.put_env(:jsonrpc2_client, :adapter, MyClient.MockAdapter)

expect(MyClient.MockAdapter, :execute, fn url, data, headers, opts ->
  # assert args if required
  # and define a return
  {:ok, %JSONRPC2.Spec.Result{value: "value"}}
end)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/jsonrpc2_client](https://hexdocs.pm/jsonrpc2_client).
