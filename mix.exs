defmodule PhxJohnElmLabs.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_john_elm_labs,
      version: "0.1.0",
      elixir: "~> 1.17",
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
      {:phx_new, "~> 1.7", only: :dev, runtime: false}
    ]
  end
end
