defmodule Hackathon.Utils.Colores do
  @moduledoc """
  Utilidades para dar formato y color a la salida de la CLI.
  Hace que la interfaz sea más elegante y facil de leer.
  """

  def exito(texto) do
    IO.ANSI.green() <> "✓ " <> texto <> IO.ANSI.reset()
  end

  def error(texto) do
    IO.ANSI.red() <> "✗ " <> texto <> IO.ANSI.reset()
  end

  def info(texto) do
    IO.ANSI.cyan() <> "ℹ " <> texto <> IO.ANSI.reset()
  end

  def advertencia(texto) do
    IO.ANSI.yellow() <> "⚠ " <> texto <> IO.ANSI.reset()
  end

  def titulo(texto) do
    ancho = String.length(texto) + 4
    borde = String.duplicate("═", ancho)

    IO.ANSI.bright() <> IO.ANSI.blue() <>
    "\n╔" <> borde <> "╗\n" <>
    "║  " <> texto <> "  ║\n" <>
    "╚" <> borde <> "╝\n" <>
    IO.ANSI.reset()
  end

  def comando(texto) do
    IO.ANSI.magenta() <> texto <> IO.ANSI.reset()
  end

  def destacado(texto) do
    IO.ANSI.bright() <> IO.ANSI.white() <> texto <> IO.ANSI.reset()
  end

  def separador do
    IO.ANSI.blue() <> String.duplicate("─", 50) <> IO.ANSI.reset()
  end
end
