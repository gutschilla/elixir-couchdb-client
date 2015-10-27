defmodule CouchdbClient.Attachment do

    alias CouchdbClient.Document

    @moduledoc """
    Add, delete and retrieve attachments to/from a document
    """
    defstruct filename: nil, content: "", content_type: "text/plain;charset=utf8"
    
    @doc """
    Returns the URL of an attachments, including revision query parameter.
    If the document hasn't been retrieved yet, a Document.get_rev (HEAD call
    to CouchDB) will be performed to retrieve the current revision
    identifier "rev"
    """
    def url( document, attachment, db ) do
        rev = case document.rev do
            nil -> Document.get_rev( document, db )
            _   -> document.rev
        end
        Document.url( document, db ) <> "/" <> attachment.filename <> "?rev=" <> rev
    end
    
    @doc """
    Adds attachment to document. Default content_type is
    "text/plain;content=utf8". Returns :ok
    
    If you wish to work further on this document you MUST call Document.load
    afterwards to update stubs and data.rev
    
    Examples:
    
    CouchdbClient.Attachment.attach(
        document, %{ filename: "test.txt", content: "Äktschn!" }, db
    )
    
    CouchdbClient.Attachment.attach(
        document,
        %CouchdbClient.Attachment{
            filename: "test.jpeg",
            content: File.read!("/home/gutschilla/test.jpeg"),
            content_type: "image/jpeg"
        },
        db
    )
    """
    def attach( document, attachment, db ) do
        url = url document, attachment, db
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
    def delete( document, filename, db ) do
        url = Attachment.url document, %CouchdbClient.Attachment{ filename: filename }, db
        response = HTTPoison.delete! url
        200 = response.status_code
        :ok
    end
    
    @doc """
    Retrieves attachment from document. Returns { content, content_type }
    """
    def fetch( document, filename, db ) do
        url = Attachment.url document, %CouchdbClient.Attachment{ filename: filename }, db
        response = HTTPoison.get! url, [], []
        200 = response.status_code
        content_type = List.keyfind( response.headers, "Content-Type", 0 )|> elem( 1 )
        { response.body, content_type }
    end

end
