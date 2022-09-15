defmodule JSONRPC2Client.Response do
  alias JSONRPC2Client.Types, as: T

  defmodule Error do
    @type t :: %__MODULE__{
      id: String.t() | integer(),
      code: String.t() | integer(),
      message: String.t(),
      data: term()
    }

    defstruct [:id, :code, :message, :data]
  end

  defmodule Result do
    @type t :: %__MODULE__{
      id: String.t() | integer(),
      value: term()
    }

    defstruct [:id, :value]
  end

  @spec parse(String.t()) :: T.result()
  def parse(""),
    do: {:ok, []}

  def parse(response) when is_binary(response) do
    with {:ok, response} <- Jason.decode(response) do
      {:ok, build(response)}
    else
      _ ->
        {:error, {:invalid_json_response, response}}
    end
  end

  @spec build(T.raw_data()) :: T.response() | [T.response()]
  def build(responses) when is_list(responses),
    do: Enum.map(responses, &(build(&1)))

  def build(%{"id" => nil, "result" => result, "jsonrpc" => "2.0"}),
    do: %Result{value: result}

  def build(%{"id" => id, "result" => result, "jsonrpc" => "2.0"}),
    do: %Result{id: id, value: result}

  def build(%{"result" => result, "jsonrpc" => "2.0"}),
    do: %Result{value: result}

  def build(%{"id" => nil, "error" => error, "jsonrpc" => "2.0"}),
    do: %Error{code: error["code"], message: error["message"], data: error["data"]}

  def build(%{"id" => id, "error" => error, "jsonrpc" => "2.0"}),
    do: %Error{id: id, code: error["code"], message: error["message"], data: error["data"]}

  def build(%{"error" => error, "jsonrpc" => "2.0"}),
    do: %Error{code: error["code"], message: error["message"], data: error["data"]}

  def build(response),
    do: client_error(response, "Invalid Response")

  defp client_error(response, message),
    do: %Error{message: message, data: response}
end
