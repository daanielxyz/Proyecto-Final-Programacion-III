defmodule Hackathon do
  @moduledoc """
  Aplicación principal para el proyecto como tal
  """

  def main(_args) do
    Hackathon.Adapters.CLI.start()
  end
end
