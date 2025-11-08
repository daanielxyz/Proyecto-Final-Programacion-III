defmodule Hackathon.Services.GestionParticipantes do
  @moduledoc """
  Service para gestionar participantes de la Hackathon.

  Casos de uso:
  - Registrar participantes
  - Listar participantes
  - Ver detalle de un participante
  """

  alias Hackathon.Domain.Participante
  alias Hackathon.Adapters.Persistencia.{RepositorioParticipantes, RepositorioEquipos}
  alias Hackathon.Core.Validaciones
  alias Hackathon.Utils.UuidHelper

  @doc """
  Registra un nuevo participante.

  ## Ejemplos
      iex> GestionParticipantes.registrar("Juan Pérez", "juan@email.com")
      {:ok, %Participante{...}}
  """
  def registrar(nombre, correo, rol \\ :participante) do
    # 1. Validar
    cond do
      not Validaciones.nombre_valido?(nombre) ->
        {:error, "El nombre debe tener al menos 3 caracteres"}

      not Validaciones.correo_valido?(correo) ->
        {:error, "El correo no es válido"}

      correo_existe?(correo) ->
        {:error, "Ya existe un participante con ese correo"}

      not rol_valido?(rol) ->
        {:error, "Rol inválido. Debe ser: participante, mentor u organizador"}

      true ->
        # 2. Crear entidad
        id = UuidHelper.generar()
        participante = Participante.nuevo(id, nombre, correo, rol)

        # 3. Guardar
        case RepositorioParticipantes.guardar(participante) do
          {:ok, participante} -> {:ok, participante}
          {:error, razon} -> {:error, "Error al guardar: #{razon}"}
        end
    end
  end

  @doc """
  Lista todos los participantes.
  """
  def listar_participantes do
    participantes = RepositorioParticipantes.leer_todos()

    # Enriquecer con información del equipo
    participantes_con_info = Enum.map(participantes, fn p ->
      nombre_equipo = case obtener_nombre_equipo(p.equipo_id) do
        {:ok, nombre} -> nombre
        {:error, _} -> nil
      end

      Map.merge(
        Map.from_struct(p),
        %{nombre_equipo: nombre_equipo}
      )
    end)

    {:ok, participantes_con_info}
  end

  @doc """
  Obtiene participantes por equipo.
  """
  def listar_por_equipo(equipo_id) do
    participantes = RepositorioParticipantes.obtener_por_equipo(equipo_id)

    participantes_info = Enum.map(participantes, fn p ->
      %{
        id: p.id,
        nombre: p.nombre,
        correo: p.correo,
        rol: p.rol
      }
    end)

    {:ok, participantes_info}
  end

  @doc """
  Obtiene información detallada de un participante por correo.
  """
  def ver_participante(correo) do
    case RepositorioParticipantes.obtener_por_correo(correo) do
      {:ok, participante} ->
        # Obtener nombre del equipo si tiene
        nombre_equipo = case obtener_nombre_equipo(participante.equipo_id) do
          {:ok, nombre} -> nombre
          {:error, _} -> nil
        end

        detalle = %{
          id: participante.id,
          nombre: participante.nombre,
          correo: participante.correo,
          rol: participante.rol,
          equipo_id: participante.equipo_id,
          nombre_equipo: nombre_equipo,
          tiene_equipo: Participante.tiene_equipo?(participante),
          fecha_registro: participante.fecha_registro
        }

        {:ok, detalle}

      {:error, _} -> {:error, "Participante no encontrado"}
    end
  end

  @doc """
  Cuenta participantes registrados.
  """
  def contar_participantes do
    RepositorioParticipantes.contar()
  end

  @doc """
  Obtiene participantes sin equipo.
  """
  def participantes_sin_equipo do
    participantes = RepositorioParticipantes.leer_todos()

    participantes
    |> Enum.filter(fn p -> not Participante.tiene_equipo?(p) end)
    |> Enum.map(fn p ->
      %{
        id: p.id,
        nombre: p.nombre,
        correo: p.correo,
        rol: p.rol
      }
    end)
  end

  # ========== FUNCIONES PRIVADAS ==========

  # Verifica si existe un participante con ese correo
  defp correo_existe?(correo) do
    case RepositorioParticipantes.obtener_por_correo(correo) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  # Valida que el rol sea válido
  defp rol_valido?(rol) do
    rol in [:participante, :mentor, :organizador]
  end

  # Obtiene el nombre del equipo dado un ID
  defp obtener_nombre_equipo(nil), do: {:error, :sin_equipo}
  defp obtener_nombre_equipo(equipo_id) do
    case RepositorioEquipos.obtener_por_id(equipo_id) do
      {:ok, equipo} -> {:ok, equipo.nombre}
      {:error, _} -> {:error, :no_encontrado}
    end
  end
end
