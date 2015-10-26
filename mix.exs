defmodule CouchdbClient.Mixfile do
  use Mix.Project

  def project do
    [app: :couchdb_client,
     version: "0.1.0",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package,
     description: description,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:poison, "~> 1.5"},
      {:httpoison, "~> 0.7.2"}
    ]
  end

  defp description do
    """
    A partial yet functional CouchDB client, with attachment support.
    """
  end

  defp package do
    [
     files: ["lib", "mix.exs", "README", "LICENSE", "test" ],
     contributors: ["Martin Gutsch"],
     licenses: ["MIT"],
     links: %{
        "GitHub" => "https://github.com/gutschilla/elixir-couchdb-client"
      }
     ]
  end

end
