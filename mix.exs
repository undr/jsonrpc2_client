defmodule JSONRPC2Client.MixProject do
  use Mix.Project

  def project do
    [
      app: :jsonrpc2_client,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0"},
      {:httpoison, "~> 1.8.1"},
      {:bypass, "~> 2.1.0", only: :test}
    ]
  end
end
