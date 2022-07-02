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

## Usage

```elixir
alias JSONRPC2Client.Response.Result
alias JSONRPC2Client.Response.Error

[%Result{}, %Error{}] =
  JSONRPC2Client.call("add", [100, 120], 1)
  |> JSONRPC2Client.call("div", [120, 0], 2)
  |> JSONRPC2Client.notify("send_event", ["user.action", %{payload: "payload"}])
  |> JSONRPC2Client.send("http://127.0.0.1:4000")
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/jsonrpc2_client](https://hexdocs.pm/jsonrpc2_client).
