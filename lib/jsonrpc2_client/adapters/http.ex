defmodule JSONRPC2Client.Adapters.HTTP do
  require Logger

  use HTTPoison.Base

  alias JSONRPC2Client.Response

  @behaviour JSONRPC2Client.Adapters.Behaviour
  @default_headers %{"content-type" => "application/json"}

  @impl true
  def execute(_url, [], _headers, _opts),
    do: {:ok, []}

  @impl true
  def execute(url, [request], headers, opts),
    do: post_request(url, Jason.encode!(request), headers(headers), opts)

  @impl true
  def execute(url, requests, headers, opts),
    do: post_request(url, Jason.encode!(requests), headers(headers), opts)

  defp post_request(url, body, headers, opts) do
    log_request(url, body, headers)

    url
    |> post(body, headers, opts)
    |> handle_http_response()
    |> handle_jsonrpc_response()
  end

  defp handle_http_response(response) do
    log_response(response)

    case response do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, {:server_error, %{code: code}}}

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, {HTTPoison.Error, %{reason: reason}}}
    end
  end

  defp handle_jsonrpc_response({:ok, response}),
    do: Response.parse(response)

  defp handle_jsonrpc_response(error),
    do: error

  defp headers(data),
    do: Map.merge(Enum.into(data, %{}), @default_headers)

  defp log_request(url, body, headers),
    do: Logger.debug("[JSONRPC2 Client] -> url: #{url}, body: #{body}, headers: #{inspect(headers)}")

  defp log_response({:ok, %HTTPoison.Response{status_code: status, body: body, headers: headers}}),
    do: Logger.debug("[JSONRPC2 Client] <- status: #{status}, body: #{body}, headers: #{inspect(headers)}")

  defp log_response({:error, %HTTPoison.Error{reason: reason}}),
    do: Logger.debug("[JSONRPC2 Client] <- error: #{reason}")
end
