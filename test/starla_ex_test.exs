defmodule StarlaExTest do
  use ExUnit.Case

  test "application module is configured" do
    assert Application.spec(:starla_ex, :mod) == {StarlaEx.Application, []}
  end
end
