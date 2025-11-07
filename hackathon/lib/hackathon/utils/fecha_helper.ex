defmodule Hackathon.Utils.FechaHelper do
  @moduledoc """
  Helper para trabajar con fechas y timestamps de manera consistente.
  """

  def ahora do
    DateTime.utc_now()
  end

  def formatear(datetime) do
    # Formato: "2024-11-06 14:30:45"
    Calendar.strftime(datetime, "%Y-%m-%d %H:%M:%S")
  end

  def formatear_corto(datetime) do
    # Formato: "14:30"
    Calendar.strftime(datetime, "%H:%M")
  end

  def desde_string(string) do
    case DateTime.from_iso8601(string) do
      {:ok, datetime, _offset} -> {:ok, datetime}
      {:error, _} -> {:error, :fecha_invalida}
    end
  end
end
