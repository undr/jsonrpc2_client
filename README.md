# JSONRPC2Client

JSONRPC2 Client

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `jsonrpc2_client` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jsonrpc2_client, "~> 0.1.0"}
  ]
end
```

## Configuration

The library provides with default `JSONRPC2Client.Adapters.HTTP` adapter. Nonetheless. it's possible to use custom adapter. It can be any module which implements `JSONRPC2Client.Adapters.Behaviour` behaviour. For example, it can be adapter built by `mox` library, to make easy to test application what using this library. However, you have to create a wrapper and

```elixir
defmodule MyClient do
  use JSONRPC2Client.Base, otp_app: :my_app
end
```

```elixir
config :my_app, MyClient, MyClient.MyAdapter
```

It's also possible explicitly to define adapter, but it won't be able to configure in runtime.

```elixir
defmodule MyClient do
  use JSONRPC2Client.Base

  def adapter do
    MyClient.MyAdapter
  end
end
```

```elixir
defmodule MyClient.MyAdapter do
  @behaviour JSONRPC2Client.Adapters.Behaviour

  def execute(url, data, headers, opts) do
    # ...
  end
end
```

## Usage

```elixir
alias JSONRPC2Client.Response.Result
alias JSONRPC2Client.Response.Error

[%Result{}, %Error{}] =
  JSONRPC2Client.call("add", [100, 120], 1)
  |> JSONRPC2Client.call("div", [120, 0], 2)
  |> JSONRPC2Client.notify("send_event", ["user.action", %{payload: "payload"}])
  |> JSONRPC2Client.send("http://127.0.0.1:4000")

[%Result{}, %Error{}] =
  MyClient.call("add", [100, 120], 1)
  |> MyClient.call("div", [120, 0], 2)
  |> MyClient.notify("send_event", ["user.action", %{payload: "payload"}])
  |> MyClient.send("http://127.0.0.1:4000")
```

## Testing

```elixir
Mox.defmock(MyClient.MockAdapter, for: JSONRPC2Client.Adapters.Behaviour)
Application.put_env(:my_app, MyClient, MyClient.MockAdapter)

expect(MyClient.MockAdapter, :execute, fn url, data, headers, opts ->
  # assert args if required
  # and define a return
  {:ok, %JSONRPC2Client.Response.Result{value: "value"}}
end)
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/jsonrpc2_client](https://hexdocs.pm/jsonrpc2_client).
