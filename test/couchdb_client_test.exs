defmodule CouchdbClientTest do
  use ExUnit.Case
  doctest CouchdbClient
  
  alias CouchdbClient.Document, as: Doc
  alias CouchdbClient.Database, as: DB

  test "load doc" do
    db  = %DB{ name: "borgmann2" }
    doc = %Doc{ _id: "blogpost,80", database: db }
    url = Doc.url( doc )
    assert "http://127.0.0.1:5984/borgmann2/blogpost,80" == url
    { :ok, response } = DB.load doc
    body = Poison.decode! r.body
  end

end
