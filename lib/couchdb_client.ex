defmodule CouchdbClient do
    @vsn "0.2.1"
    
    @moduledoc """
    This module conveniently interfaces/proxies 
     
     - CouchdbClient.Repository
     - CouchdbClient.Database
     - CouchdbClient.Document
     - CouchdbClient.Attachment
     
    to provide easy access to a CouchDB instance:
     
    ## Examples
     
    iex> CouchdbClient.start name: "test_database"
     _PID
     
    iex> doc = %CouchdbClient.Document{ data: %{ "one" => "two" } }
    %CouchdbClient.Document{data: %{"one" => "two"}, id: nil, rev: nil}
    
    iex> doc = CouchdbClient.save doc
    %CouchdbClient.Document{data: %{"_rev" => _REV1, "one" => "two"}, id: _ID, rev: _REV1}
    
    iex> CouchdbClient.delete doc
    :ok

    iex> doc = %CouchdbClient.Document{ id: "test_doc", data: %{ "one" => "two" } }
    %CouchdbClient.Document{id: "test_doc", data: %{"one" => "two"}, id: "test_doc", rev: nil}
    
    iex> doc = CouchdbClient.save doc
    %CouchdbClient.Document{data: %{"_rev" => _REV2, "one" => "two"}, id: "test_doc", rev: _REV2}
    
    """
    
    alias CouchdbClient.Repository, as: Repo
    alias CouchdbClient.Database,   as: DB
    alias CouchdbClient.Document,   as: Doc
    alias CouchdbClient.Attachment, as: Attachment

    def start( db_options ) do
        Repo.start_link db_options
    end
    def db do
        Repo.get
    end
    def load( id ) when is_binary( id ) do
        Doc.load %Doc{ id: id }, db
    end
    def load( id ) when is_integer( id ) do
        Doc.load %Doc{ id: "#{id}" }, db
    end
    def load( document ) do
        Doc.load document, db
    end
    def get_rev( document ) do
        Doc.get_rev document, db
    end
    def set( document, data ) do
        Doc.set( document, data )
    end
    def insert( document ) do
        Doc.insert document, db
    end
    def update( document ) do
        Doc.update document, db
    end
    def save( document ) do
        Doc.save document, db
    end
    def delete( document ) do
        Doc.delete document, db
    end
    def add_attachment( document, attachment ) do
        Attachment.attach( document, attachment, db )
    end
    def delete_attachment( document, filename ) do
        Attachment.delete_attachment( document, filename , db )
    end
    def fetch_attachment( document, filename ) do
        Attachment.attach( document, filename, db )
    end

end
