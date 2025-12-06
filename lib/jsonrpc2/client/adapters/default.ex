if Code.ensure_loaded?(HTTPoison) do
  defmodule JSONRPC2.Client.Adapters.Default do
    require Logger
    @behaviour JSONRPC2.Client.Adapters.Behaviour

    use HTTPoison.Base

    alias JSONRPC2.Spec.Error
    alias JSONRPC2.Spec.Response

    @default_headers %{"content-type" => "application/json"}

    @impl true
    def execute(_url, [], _opts) do
      nil
    end

    @impl true
    def execute(url, [request], opts) do
      post_request(url, JSON.encode!(request), opts)
    end

    @impl true
    def execute(url, requests, opts) do
      post_request(url, JSON.encode!(requests), opts)
    end

    defp post_request(url, body, opts) do
      {headers, opts} = Keyword.pop(opts, :headers)
      headers = headers(headers)

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
          {:error, %{reason: reason}}
      end
    end

    defp handle_jsonrpc_response({:ok, response}) do
      Response.parse(response)
    end

    defp handle_jsonrpc_response({:error, {:server_error, reason}}) do
      Error.new(nil, :server_error, reason)
    end

    defp handle_jsonrpc_response({:error, reason}) do
      Error.new(nil, -32000, "Network Error", reason)
    end

    defp headers(nil) do
      @default_headers
    end

    defp headers(data) do
      Map.merge(Enum.into(data, %{}), @default_headers)
    end

    defp log_request(url, body, headers) do
      Logger.debug("[JSONRPC2 Client] -> url: #{url}, body: #{body}, headers: #{inspect(headers)}")
    end

    defp log_response({:ok, %HTTPoison.Response{status_code: status, body: body, headers: headers}}) do
      Logger.debug("[JSONRPC2 Client] <- status: #{status}, body: #{body}, headers: #{inspect(headers)}")
    end

    defp log_response({:error, %HTTPoison.Error{reason: reason}}) do
      Logger.debug("[JSONRPC2 Client] <- error: #{reason}")
    end
  end
end
