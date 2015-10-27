# CouchdbClient

A minimal yet functional CouchDB client, with attachment support. Currently, this is a result of an evening hacking so expect quite a few API changes until 1.0.

## Error handling

Not in here ;-) No exception handling is performed. Server responses are expected to be 200 OK or 201 CREATED. If anything fails, the code will simply crash (with a badmatch or the like). 

## Future development

There will be `method` functions that eitehr return `{:ok, result}` or `{:error, reason}` tuples and corresponding `method!` bang!-functions either return the result or crash with some sensible error, most likely the bare HTTP result from HTTPpoison.

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

The package can be installed as:

  1. Add elixir_couchdb_client to your list of dependencies in `mix.exs`:

        def deps do
          [{:couchdb_client, "~> 0.1.0"}]
        end

  2. Ensure couchdb_client is started before your application:

        def application do
          [applications: [:couchdb_client]]
        end
