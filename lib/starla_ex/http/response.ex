defmodule StarlaEx.HTTP.Response do
  import Plug.Conn

  alias StarlaEx.Domain.ProtocolError

  @spec json(Plug.Conn.t(), pos_integer(), term()) :: Plug.Conn.t()
  def json(conn, status, payload) do
    body = Jason.encode!(payload)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end

  @spec error(Plug.Conn.t(), ProtocolError.t()) :: Plug.Conn.t()
  def error(conn, error) do
    json(conn, ProtocolError.status(error), ProtocolError.body(error))
  end
end
