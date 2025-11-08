
defmodule Hackathon.Adapters.CLI do
  @moduledoc """
  Punto de entrada principal de la CLI.
  Maneja el loop de lectura-evaluación-impresión (REPL).
  """

  alias Hackathon.Adapters.CLI.{Parser, Comandos, UI}

  @doc """
  Inicia la CLI interactiva.
  """
  def start do
    UI.mostrar_banner()
    loop()
  end

  # Loop principal de la CLI.
  # Lee entrada del usuario, parsea y ejecuta comandos.
  defp loop do
    UI.prompt()

    entrada = IO.gets("") |> String.trim()

    comando = Parser.parsear(entrada)

    case Comandos.ejecutar(comando) do
      :salir -> :ok
      :continuar -> loop()
    end
  end
end
