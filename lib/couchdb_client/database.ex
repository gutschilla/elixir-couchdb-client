defmodule CouchdbClient.Database do
    
    defmodule Error do
        defexception message: "database error"
    end
    
    @moduledoc """
    Struct that holds database connection options:
     
     - scheme: String, either "http" (default) or "https"
     - host: String, IP or hostname (default 127.0.0.1)
     - port: Integer (default 5984)
     - name: Name of CouchDB database to connect to
     
    """
    defstruct scheme: "http", host: "127.0.0.1", port: 5984, name: nil
    
    @doc """
    Constructs Database URL from CouchdbClient.Database struct. Returns a
    string.
    
    ## Examples
    
    iex> CouchdbClient.Database.url %CouchdbClient.Database{ name: "test" }
    "http://127.0.0.1:5984/test"
    
    """
    def url( database ) do
        Enum.join [
            database.scheme,
            "://",
            database.host,
            ":", database.port,
            "/", database.name
        ], ""
    end
    
    def all_docs database do
        response = database
        |> url
        |> HTTPoison.get!
        if response.status_code != 200, do: raise Error, message: inspect response
        Poison.decode! response.body
    end
    
end
