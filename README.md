# ElixirCouchdbClient

A minimal yet functional CouchDB client, with attachments.

.. not yet done. Loading, updating (after load), delete works. Attachments aren't yet dupported.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add elixir_couchdb_client to your list of dependencies in `mix.exs`:

        def deps do
          [{:elixir_couchdb_client, "~> 0.0.1"}]
        end

  2. Ensure elixir_couchdb_client is started before your application:

        def application do
          [applications: [:elixir_couchdb_client]]
        end
