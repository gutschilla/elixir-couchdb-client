# CouchdbClient

A minimal yet functional CouchDB client, with attachment support. Currently,
this is a result of an evening hacking so expect quite a few API changes until
1.0.

## Error handling

Not in here ;-) No exception handling is performed. Server responses are
expected to be 200 OK or 201 CREATED. If anything fails, the code will simply
crash (with a badmatch or the like). 

## Future development

There will be `method` functions that eitehr return `{:ok, result}` or `{:error,
reason}` tuples and corresponding `method!` bang!-functions either return the
result or crash with some sensible error, most likely the bare HTTP result from
HTTPpoison.

## Usage

For full documentation, see inline @doc or use ex_doc to generate docs.

### Using as OTP Application

The package can be installed as:

  1. Add couchdb_client to your list of dependencies in `mix.exs`:

        def deps do
          [{:couchdb_client, "~> 0.3.2"}]
        end

  2. Configure CouchDB connection parameters in your `config.exs`

        config :couchdb_client,
            scheme: "http",
            host:   "127.0.0.1",
            port:   5984,
            name:   "you_database_name"

  3. Ensure couchdb_client is started before your application:

        def application do
          [applications: [:couchdb_client]]
        end


### Using CouchdbClient's wrapper

This will save the connection info in an Elixir.Agent process.

```
CouchdbClient.start host: "10.0.0.1", port: 5984, name: "test_database"
doc = %CouchdbClient.Document{ data: %{ "foo" => "bar" } }
doc = CouchdbClient.save doc
doc = CouchdbClient.set doc, %{ "boom" => "bang" }
doc = CouchdbClient.save doc
attachment = %CouchdbClient.Attachment{ filename: "test.jpg", content: File.read!("test.jpg"), content_type: "image/jpeg" }
:ok = CouchdbClient.add_attachment doc, attachment
{ binary, content_type } = CouchdbClient.fetch_attachment "test.jpg"
:ok = CouchdbClient.delete_attachment doc, attachment
```

### Using CouchdbClient's modules directly
```
alias CouchdbClient.Database,   as: DB
alias CouchdbClient.Document,   as: Doc
alias CouchdbClient.Attachment, as: Attachment

db  = %DB{ host: "127.0.0.1", port: "5984", name: "test_database" }
doc = %Doc{ _id: "test_document", _data: %{ "foo" => "bar" } }
doc = Doc.insert doc, db
doc = Doc.set doc, %{ "bang" => "boom" } # inserts(!) "bang" => "boom" in data
doc = Doc.update doc, db
doc = Doc.save doc, db # save automatically uses insert or update 
:ok = Doc.delete doc, db 

attachment = %Attachment{ filename: "test.jpg", content: File.read!("test.jpg"), content_type: "image/jpeg" }
:ok = Attachment.attach( doc, attachment, db )

attachment2 = %Attachment{ filename: "test.txt", content: "Müßiggang!", content_type: "text/plain;charset=utf8" }
# attaching to a document w/o _rev will auto-fetch the current revision rev:
:ok = Attachment.attach( %Doc{ _id: doc._id, database: doc.database }, attachment2 )

# or just load to refresh:
doc = Document.load doc, db
:ok = Attachment.delete doc, "test.jpg", db
{ binary, content_type } = Attachment.fetch doc, "test.txt", db
```
