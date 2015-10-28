defmodule CouchdbClient.Repository do
    @moduledoc """
    Agent to keep db connection options.
    
    ## Examples
    
    iex> CouchdbClient.Repository.start_link name: "test_database"
    { :ok, _PID }
    iex> CouchdbClient.Repository.get
    %CouchdbClient.Database{host: "127.0.0.1", name: "test_database", port: 5984, scheme: "http"}
    iex> CouchdbClient.Repository.stop
    :ok
    
    """
    @name __MODULE__
    
    @doc "Starts the Repository agent, returns PID"
    def start_link( db_options ) do
      Agent.start_link( __MODULE__, :init_opts, [ db_options ], name: @name  )
    end

    def init_opts( db_options ) do
        options = Enum.into db_options, %{}
        Map.merge %CouchdbClient.Database{}, options
    end

    @doc "Stops Repository agent, returns :ok"
    def stop do
      Agent.stop @name
    end

    @doc "Returns the CouchdbClient.Repository configuration as struct"
    def get do
      Agent.get( @name, fn( data ) -> data end )
    end
end
