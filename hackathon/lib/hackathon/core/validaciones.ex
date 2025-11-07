defmodule Hackathon.Core.Validaciones do
  @moduledoc """
  Funciones de validación comunes para toda la aplicación.
  Mantiene las reglas de negocio centralizadas.
  """

  def nombre_valido?(nombre) when is_binary(nombre) do
    String.trim(nombre) != "" and String.length(nombre) >= 3
  end
  def nombre_valido?(_), do: false

  def correo_valido?(correo) when is_binary(correo) do
    String.contains?(correo, "@") and String.contains?(correo, ".")
  end
  def correo_valido?(_), do: false

  def categoria_proyecto_valida?(categoria) do
    categoria in ["social", "ambiental", "educativo"]
  end

  def estado_proyecto_valido?(estado) do
    estado in ["idea", "desarrollo", "finalizado"]
  end

  def lista_no_vacia?(lista) when is_list(lista) do
    length(lista) > 0
  end
  def lista_no_vacia?(_), do: false

  def texto_no_vacio?(texto) when is_binary(texto) do
    String.trim(texto) != ""
  end
  def texto_no_vacio?(_), do: false
end
