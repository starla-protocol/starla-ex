defmodule StarlaEx.Domain.Sessions do
  @states [:open, :closed, :deleted]

  defmodule Session do
    @enforce_keys [:session_id, :state]
    @derive {Jason.Encoder, only: [:session_id, :state]}
    defstruct [:session_id, :state, :session_material]

    @type t :: %__MODULE__{
            session_id: String.t(),
            state: :open | :closed | :deleted,
            session_material: map() | nil
          }
  end

  @spec new_session(String.t(), atom(), map() | nil) :: Session.t()
  def new_session(session_id, state, session_material) when state in @states do
    %Session{
      session_id: session_id,
      state: state,
      session_material: session_material
    }
  end

  @spec close_session(Session.t()) :: {:ok, Session.t()} | {:error, :invalid_state}
  def close_session(%Session{state: :open} = session) do
    {:ok, %{session | state: :closed}}
  end

  def close_session(%Session{}), do: {:error, :invalid_state}
end
