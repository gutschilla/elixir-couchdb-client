# CouchdbClient

A minimal yet functional CouchDB client, with attachment support.

## Usage

For full documentation, see inline @doc or use ex_doc to generate docs.

```
alias CouchdbClient.Database,   as: DB
alias CouchdbClient.Document,   as: Doc
alias CouchdbClient.Attachment, as: Attachment

db  = %DB{ host: "127.0.0.1", port: "5984", name: "test_database" }
doc = %Doc{ _id: "test_document", _data: %{ "foo" => "bar" }, database: db }
doc = Doc.insert doc
doc = %{ doc | _data: %{ "foo" => "boom" } }
doc = Doc.update doc
:ok = Doc.delete doc

attachment = %Attachment{ filename: "test.jpg", content: File.read!("test.jpg"), content_type: "image/jpeg" }
:ok = Attachment.attach( doc, attachment )

attachment2 = %Attachment{ filename: "test.txt", content: "Müßiggang!", content_type: "text/plain;charset=utf8" }
# attaching to a document w/o _rev will auto-fetch the current revision rev:
:ok = Attachment.attachment2( %Doc{ _id: doc._id, database: doc.database }, attachment2 )

# or just load to refresh:
doc = Document.load doc
:ok = Attachment.delete( doc, "test.jpg" )
{ binary, content_type } = Attachment.fetch( doc, "test.txt" )
```

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
