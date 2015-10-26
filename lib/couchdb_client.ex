defmodule CouchdbClient do
    defmodule Database do
        defstruct scheme: "http://", host: "127.0.0.1", port: 5984, name: nil
        def url( database ) do
            Enum.join [
                database.scheme,
                database.host,
                ":", database.port,
                "/", database.name
            ], ""
        end
    end
    defmodule Document do
            
        @vsn "0.1.0"
        @moduledoc """
            Very minimalistic wrapper around CouchDB API (tested against CouchDB
            1.5.0). Usage:
            
            ```
            alias CouchdbClient.Database, as: DB
            alias CouchdbClient.Document, as: Doc
            db  = %DB{ host: "127.0.0.1", port: "5984", name: "test_database" }
            doc = %Doc{ _id: "test_document", _data: %{ "foo" => "bar" }, database: db }
            doc = Doc.insert doc 
            doc = %{ doc | _data: %{ "foo" => "boom" } }
            doc = Doc.update doc 
            :ok = Doc.delete doc 
            ```
        """
    
        @headers [ { "Content-Type", "application/json" } ]
        defstruct _id: nil, _rev: nil, database: nil, _data: %{}

        @doc """
            Returns The document's URL
        """
        def url( document ) do
            Database.url( document.database ) <> "/" <> document._id
        end
        
        @doc """
            Loads the document from DB. Both :database and :_id attributes must
            be set for this to work.
        """
        def load( document ) do
            response = document |> url |> HTTPoison.get!
            200 = response.status_code # assert 200 ok status
            body = Poison.decode! response.body
            %{ document |
                _rev: body["_rev"],
                _data: body
            }
        end
        
        @doc """
            Performs a HEAD request to CouchDB to retrieve the current revision
            tag. This is useful if you'd like to attach files to a document you
            don't actually have already loaded.
            
            Returns a document with data set to nil to prevent this document to
            be saved.
        """
        def get_rev( document ) do
            response = document |> url |> HTTPoison.head!
            headers  = response.headers
            List.keyfind( headers, "ETag", 0 )
                |> elem(1)
                |> String.lstrip( ?" )
                |> String.rstrip( ?" )            
        end

        @doc """
            Inserts document. If document has no ID, a server-generated id will
            be set. Returns freshly inserted document (with id/rev)            
        """
        def insert( document ) do
            { method, url } = case document._id do
                nil -> { &HTTPoison.post!/4, Database.url( document.database ) }
                _   -> { &HTTPoison.put!/4,  Document.url( document ) }
            end
            response = method.( url, Poison.encode!( document._data ), @headers, [] )
            201 = response.status_code # assert 201 created status
            body = Poison.decode! response.body
            %{ document |
                _id:  body["id"],
                _rev: body["rev"],
            }
        end
        
        @doc """
            Updates document.
        """
        def update( document ) do
            url = Document.url( document )
            response = HTTPoison.put!( url, Poison.encode!( document._data ), @headers, [] )
            201 = response.status_code # assert 201 created status (yeah, update yields "created" in CouchDB)
            body = Poison.decode! response.body
            %{ document | _rev: body["rev"] }
        end
        
        @doc """
            Inserts or updates a document. Returns inserted/updated document.
        """
        def save( document ) do
            case document._rev do
                nil -> insert( document )
                _   -> update( document )
            end
        end

        @doc """
            Deletes the document. Returns :ok
        """
        def delete( document ) do
            url = Document.url( document )
            response = HTTPoison.delete!( url, [{"If-Match", document._rev }], [] )
            200 = response.status_code
            :ok
        end
        
    end
    defmodule Attachment do
        @vsn "0.1.0"
        @moduledoc """
            Add, delete and retrieve attachments to/from a document
        """
        defstruct filename: nil, content: "", content_type: "text/plain;charset=utf8"
        
        @doc """
            Returns the URL of an attachments, including revision query
            parameter. If the document hasn't been retrieved yet, a
            Document.get_rev (HEAD call to CouchDB) will be performed to
            retrieve the current revision identifier "rev"
        """
        def url( document, attachment ) do
            rev = case document._rev do
                nil -> Document.get_rev( document )
                _   -> document._rev
            end
            Document.url( document ) <> "/" <> attachment.filename <> "?rev=" <> rev
        end
        
        @doc """
            Adds attachment to document. Default content_type is
            "text/plain;content=utf8". Returns :ok
            
            Examples:
            
            CouchdbClient.Attachment.attach(
                document, %{ filename: "test.txt", content: "Äktschn!" }    
            )
            
            CouchdbClient.Attachment.attach(
                document,
                %CouchdbClient.Attachment{
                    filename: "test.jpeg",
                    content: File.read!("/home/gutschilla/test.jpeg"),
                    content_type: "image/jpeg"
                }
            )
        """
        def attach( document, attachment ) do
            url = Attachment.url document, attachment
            content_list = :binary.bin_to_list attachment.content
            headers = [
                { "Content-Length", length( content_list ) },
                { "Content-Type", attachment.content_type }
            ]
            response = HTTPoison.put! url, attachment.content, headers
            201 = response.status_code
            :ok
        end
        
        @doc """
            Removes attachment from document. Returns :ok
        """
        def delete( document, filename ) do
            url = Attachment.url document, %Attachment{ filename: filename }
            response = HTTPoison.delete! url
            200 = response.status_code
            :ok
        end
        
        @doc """
            Retrieves attachment from document. Returns { content, content_type }
        """
        def fetch( document, filename ) do
            url = Attachment.url document, %Attachment{ filename: filename }
            response = HTTPoison.get! url, [], []
            200 = response.status_code
            content_type = List.keyfind( response.headers, "Content-Type", 0 )|> elem( 1 )
            { response.body, content_type }
        end
    end
end
