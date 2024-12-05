defmodule PhxJohnElmLabs.MixProject do
  use Mix.Project

  def project do
    [
      app: :phx_john_elm_labs,
      version: "0.1.0",
      elixir: "~> 1.12",
      package: package(),
      start_permanent: Mix.env() == :prod,
      description: "A wrapper for mix phx.new with better defaults. Use UUIDs by default, opinionated project formatting, and automated test running",
      deps: deps()
    ]
  end

  defp package do
    [
      name: :phx_new_john_elm_labs,
      maintainers: ["John Elm", "John Curran"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/John-Elm/phx_gen_auth_john_elm_labs"}
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
      {:phx_new, "~> 1.7", only: :dev, runtime: false},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
