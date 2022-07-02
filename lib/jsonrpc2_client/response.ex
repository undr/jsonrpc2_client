defmodule JSONRPC2Client.Response do
  defmodule Error do
    defstruct [:id, :code, :message, :data]
  end

  defmodule Result do
    defstruct [:id, :value]
  end

  def parse(""),
    do: []
  def parse(response) when is_binary(response) do
    with {:ok, response} <- Poison.decode(response) do
      parse(response)
    else
      _ -> {:error, {:invalid_json_response, response}}
    end
  end
  def parse(responses) when is_list(responses),
    do: Enum.map(responses, &parse/1)
  def parse(%{"id" => nil, "result" => result, "jsonrpc" => "2.0"}),
    do: %Result{value: result}
  def parse(%{"id" => id, "result" => result, "jsonrpc" => "2.0"}),
    do: %Result{id: id, value: result}
  def parse(%{"result" => result, "jsonrpc" => "2.0"}),
    do: %Result{value: result}
  def parse(%{"id" => nil, "error" => error, "jsonrpc" => "2.0"}),
    do: %Error{code: error["code"], message: error["message"], data: error["data"]}
  def parse(%{"id" => id, "error" => error, "jsonrpc" => "2.0"}),
    do: %Error{id: id, code: error["code"], message: error["message"], data: error["data"]}
  def parse(%{"error" => error, "jsonrpc" => "2.0"}),
    do: %Error{code: error["code"], message: error["message"], data: error["data"]}
  def parse(response),
    do: client_error(response, "Invalid Response")

  defp client_error(response, message),
    do: %Error{message: message, data: response}
end
