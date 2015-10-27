defmodule CouchdbClient.Document do

    alias CouchdbClient.Database
        
    @moduledoc """
    Very minimalistic wrapper around CouchDB API (tested against CouchDB
    1.5.0).
    
    ## Examples
    
    iex> alias CouchdbClient.Database, as: DB
    nil
    
    iex> alias CouchdbClient.Document, as: Doc
    nil
    
    iex> db  = %DB{ host: "127.0.0.1", port: "5984", name: "test_database" }
    %CouchdbClient.Database{host: "127.0.0.1", name: "test_database", port: "5984", scheme: "http"}
    
    iex> doc = %Doc{ id: "test_document", data: %{ "foo" => "bar" } }
    %CouchdbClient.Document{data: %{"foo" => "bar"}, id: "test_document", rev: nil}
    
    iex> doc = Doc.insert doc, db
    %CouchdbClient.Document{data: %{"_rev" => _REV1, "foo" => "bar"}, id: "test_document", rev: _REV1 }
    
    iex> doc = Doc.set doc, %{ "boom" => "bang" }
    %CouchdbClient.Document{data: %{"_rev" => _REV1, "boom" => "bang", "foo" => "bar"}, id: "test_document", rev: _REV1 }
    
    iex> doc = Doc.update doc, db 
    %CouchdbClient.Document{data: %{"_rev" => rev2, "boom" => "bang", "foo" => "bar"}, id: "test_document", rev: rev2 }

    iex> Doc.get_rev doc, db 
    rev2
    
    iex> Doc.delete doc, db
    :ok
    
    """

    @headers [ { "Content-Type", "application/json" } ]
    defstruct id: nil, rev: nil, data: %{}

    @doc """
    Returns the document's URL
    """
    def url( document, db ) do
        Database.url( db ) <> "/" <> document.id
    end
    
    @doc """
    Merges data into document's data.
    
    doc = CouchdbClient.Document.set document, %{ bar: "baz" }
    """
    def set( document, data ) do
        data = Map.merge document.data, data
        Map.put document, :data, data
    end
    
    @doc """
    Loads the document from DB. Both :database and :id attributes must be set
    for this to work.
    """
    def load( document, db ) do
        response = document |> url( db ) |> HTTPoison.get!
        200 = response.status_code # assert 200 ok status
        body = Poison.decode! response.body
        %{ document |
            rev: body["_rev"],
            data: body
        }
    end
    
    @doc """
    Performs a HEAD request to CouchDB to retrieve the current revision tag.
    This is useful if you'd like to attach files to a document you don't
    actually have already loaded.
    
    Returns a document with data set to nil to prevent this document to
    be saved.
    """
    def get_rev( document, db ) do
        response = document |> url( db ) |> HTTPoison.head!
        headers  = response.headers
        List.keyfind( headers, "ETag", 0 )
            |> elem(1)
            |> String.lstrip( ?" )
            |> String.rstrip( ?" )            
    end

    @doc """
    Inserts document. If document has no ID, a server-generated id will be
    set. Returns freshly inserted document (with id/rev) 
    """
    def insert( document, db ) do
        { method, url } = case document.id do
            nil -> { &HTTPoison.post!/4, Database.url( db ) }
            _   -> { &HTTPoison.put!/4,  url( document, db ) }
        end
        response = method.( url, Poison.encode!( document.data ), @headers, [] )
        201 = response.status_code # assert 201 created status
        body = Poison.decode! response.body
        # set both document.data._rev and document.rev
        set(
            %{ document | id:  body["id"], rev: body["rev"], },
            %{ "_rev" => body["rev"] }
        )
    end
    
    @doc """
    Updates document.
    """
    def update( document, db ) do
        url = url( document, db )
        response = HTTPoison.put!( url, Poison.encode!( document.data ), @headers, [] )
        201 = response.status_code # assert 201 created status (yeah, update yields "created" in CouchDB)
        body = Poison.decode! response.body
        # set both document.data._rev and document.rev
        set %{ document | rev: body["rev"] }, %{ "_rev" => body["rev"] }
    end
    
    @doc """
    Inserts or updates a document. Returns inserted/updated document.
    """
    def save( document, db ) do
        case document.rev do
            nil -> insert( document, db )
            _   -> update( document, db )
        end
    end

    @doc """
    Deletes the document. Returns :ok
    """
    def delete( document, db ) do
        url = url( document, db )
        response = HTTPoison.delete!( url, [{"If-Match", document.rev }], [] )
        200 = response.status_code
        :ok
    end
    
end
