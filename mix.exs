defmodule JSONRPC2.Client.MixProject do
  use Mix.Project

  def project do
    [
      app: :jsonrpc2_client,
      version: "2.0.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      maintainers: ["Andrei Lepeshkin"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/undr/jsonrpc2_client"}
    ]
  end

  def description do
    "HTTP client for JSONRPC 2.0 protocol."
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 2.0", optional: true},
      {:jsonrpc2_spec, "~> 0.1.0"},
      {:bypass, "~> 2.1.0", only: :test},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
