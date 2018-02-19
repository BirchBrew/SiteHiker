defmodule AWIS.MixProject do
  use Mix.Project

  def project do
    [
      app: :awis,
      version: "0.1.0",
      elixir: "~> 1.6",
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
      # HTTP Client
      {:httpoison, "~> 1.0"},
      # AWS Request Signing
      {:sigaws, "~> 0.7"},
      # XML Parser
      {:quinn, "~> 1.1.2"}
    ]
  end
end
