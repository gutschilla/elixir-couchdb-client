defmodule CouchdbClient do

    @vsn "0.2.3"
    
    @moduledoc """
    This module conveniently interfaces/proxies 
     
     - CouchdbClient.Repository
     - CouchdbClient.Database
     - CouchdbClient.Document
     - CouchdbClient.Attachment
     
    to provide easy access to a CouchDB instance. It will collect connection
    data from Application.get_env(:couchdb_client, options) that you may
    possibly configure via 

        config :couchdb_client,
            scheme: "http",
            host:   "127.0.0.1",
            port:   5984,
            name:   "test_database"
    
    in your config/config.exs. Add :couchdb_client to your mix.exs:

        def application do
            [applications: [ .., :couchdb_client, ..], .. ]
        end
        
    If you don't want to autostart, issue
    
        CouchdbClient.start name: "test_database", host: "..", ..

    ## Examples
     
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
    alias CouchdbClient.Document,   as: Doc
    alias CouchdbClient.Database,   as: DB
    alias CouchdbClient.Attachment, as: Attachment

    use Application
    
    # See http://elixir-lang.org/docs/stable/elixir/Application.html
    # for more information on OTP Applications
    def start(_type, _args) do
        import Supervisor.Spec, warn: false
      
        children = [
          # Define workers and child supervisors to be supervised
          # worker(NavigationTree.Worker, [arg1, arg2, arg3])
            worker( Repo, [
                [
                    scheme: Application.get_env(:couchdb_client, :scheme ) || "http",
                    host:   Application.get_env(:couchdb_client, :host   ) || "127.0.0.1",
                    post:   Application.get_env(:couchdb_client, :port   ) || 5984,
                    name:   Application.get_env(:couchdb_client, :name   ),
                ]
            ] )
        ]
      
        # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
        # for other strategies and supported options
        opts = [strategy: :one_for_one, name: NavigationTree.Supervisor]
        Supervisor.start_link(children, opts)
    end

    def start_repo( db_options ) do
        Repo.start_link db_options
    end
    @doc "Returns the %CouchdbClient.Database{} stored in Repository Agent"
    def db do
        Repo.get
    end
    @doc """
    Loads a document. Accepts both an id string or a %CouchdbClient.Document
    struct which must have the id property set.
    """ 
    def load( id ) when is_binary( id ) do
        Doc.load %Doc{ id: id }, db
    end
    def load( id ) when is_integer( id ) do
        Doc.load %Doc{ id: "#{id}" }, db
    end
    def load( document ) do
        Doc.load document, db
    end
    @doc "Performs a HEAD request to CouchDB, returning the revision \"rev\"."
    def get_rev( document ) do
        Doc.get_rev document, db
    end
    @doc "Sets all keys found in data map in document.data"
    def set( document, data ) do
        Doc.set( document, data )
    end
    @doc "Inserts the document, returns it"
    def insert( document ) do
        Doc.insert document, db
    end
    @doc "Updates the document, returns it"
    def update( document ) do
        Doc.update document, db
    end
    @doc "Either inserts or updates the document, returns it"
    def save( document ) do
        Doc.save document, db
    end
    @doc "Deletes the document, return :ok"
    def delete( document ) do
        Doc.delete document, db
    end
    @doc "Adds an attachment, see CouchdbClient.Attachment.attach/3"
    def add_attachment( document, attachment ) do
        Attachment.attach( document, attachment, db )
    end
    @doc "Deletes an attachment, see CouchdbClient.Attachment.attach/3"
    def delete_attachment( document, filename ) do
        Attachment.delete( document, filename , db )
    end
    @doc """
    Fetches an attachment, returns { content, content_type }.
    See CouchdbClient.Attachment.fetch/3
    """
    def fetch_attachment( document, filename ) do
        Attachment.fetch( document, filename, db )
    end
    @doc "Returns a list of all documents in db"
    def all_docs, do: DB.all_docs db
    @doc "Retrieves general DB information from server"
    def info, do: DB.info db
    @doc "Changes the database name to use on current CouchDB server"
    def change_db name do
        Repo.change_db name
    end

end
