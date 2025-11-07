defmodule Hackathon.Utils.UuidHelper do
  @moduledoc """
  Helper para generar IDs únicos de manera consistente en toda la aplicación.
  """

  def generar do
    # Genera un UUID v4 único
    UUID.uuid4()
  end

  def generar_corto do
    # Genera un ID más corto para mostrar en UI (primeros 8 caracteres)
    UUID.uuid4() |> String.slice(0, 8)
  end
end
