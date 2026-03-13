defmodule StarlaEx.Domain.ProtocolError do
  @type t :: :not_found | :invalid_state | :capability_denied

  @spec status(t()) :: pos_integer()
  def status(:not_found), do: 404
  def status(:invalid_state), do: 409
  def status(:capability_denied), do: 403

  @spec code(t()) :: String.t()
  def code(:not_found), do: "not_found"
  def code(:invalid_state), do: "invalid_state"
  def code(:capability_denied), do: "capability_denied"

  @spec body(t()) :: map()
  def body(error) do
    %{error: %{code: code(error)}}
  end
end
