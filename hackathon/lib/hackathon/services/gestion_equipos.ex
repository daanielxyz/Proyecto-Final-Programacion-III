defmodule Hackathon.Services.GestionEquipos do
  @moduledoc """
  Service para gestionar equipos de la Hackathon.

  Casos de uso:
  - Crear equipos
  - Listar equipos
  - Ver detalle de un equipo
  - Agregar integrantes
  """

  alias Hackathon.Domain.{Equipo, Participante}
  alias Hackathon.Adapters.Persistencia.{RepositorioEquipos, RepositorioParticipantes}
  alias Hackathon.Core.Validaciones
  alias Hackathon.Utils.UuidHelper

  @doc """
  Crea un nuevo equipo.

  ## Ejemplos
      iex> GestionEquipos.crear_equipo("Los Crackers")
      {:ok, %Equipo{nombre: "Los Crackers", ...}}
  """
  def crear_equipo(nombre) do
    # 1. Validar
    cond do
      not Validaciones.nombre_valido?(nombre) ->
        {:error, "El nombre debe tener al menos 3 caracteres"}

      equipo_existe?(nombre) ->
        {:error, "Ya existe un equipo con ese nombre"}

      true ->
        # 2. Crear entidad
        id = UuidHelper.generar()
        equipo = Equipo.nuevo(id, nombre)

        # 3. Guardar
        case RepositorioEquipos.guardar(equipo) do
          {:ok, equipo} -> {:ok, equipo}
          {:error, razon} -> {:error, "Error al guardar: #{razon}"}
        end
    end
  end

  @doc """
  Lista todos los equipos registrados.
  """
  def listar_equipos do
    equipos = RepositorioEquipos.leer_todos()

    # Enriquecer con información adicional
    equipos_con_info = Enum.map(equipos, fn equipo ->
      cantidad_integrantes = length(equipo.integrantes)
      tiene_proyecto = not is_nil(equipo.proyecto_id)

      Map.merge(
        Map.from_struct(equipo),
        %{
          cantidad_integrantes: cantidad_integrantes,
          tiene_proyecto: tiene_proyecto
        }
      )
    end)

    {:ok, equipos_con_info}
  end

  @doc """
  Obtiene la información detallada de un equipo.
  Incluye nombres de los integrantes y datos del proyecto.
  """
  def ver_equipo(nombre_o_id) do
    case obtener_equipo(nombre_o_id) do
      {:ok, equipo} ->
        # Obtener información de integrantes
        integrantes = Enum.map(equipo.integrantes, fn id ->
          case RepositorioParticipantes.obtener_por_id(id) do
            {:ok, p} -> %{id: p.id, nombre: p.nombre, correo: p.correo}
            {:error, _} -> %{id: id, nombre: "Desconocido", correo: "N/A"}
          end
        end)

        # Construir respuesta detallada
        detalle = %{
          id: equipo.id,
          nombre: equipo.nombre,
          estado: equipo.estado,
          fecha_creacion: equipo.fecha_creacion,
          integrantes: integrantes,
          cantidad_integrantes: length(integrantes),
          proyecto_id: equipo.proyecto_id,
          tiene_proyecto: not is_nil(equipo.proyecto_id)
        }

        {:ok, detalle}

      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Agrega un participante a un equipo.
  """
  def unir_participante_a_equipo(participante_id, nombre_equipo) do
    with {:ok, participante} <- RepositorioParticipantes.obtener_por_id(participante_id),
         {:ok, equipo} <- obtener_equipo(nombre_equipo),
         :ok <- validar_puede_unirse(participante, equipo),
         {:ok, equipo_actualizado} <- Equipo.agregar_integrante(equipo, participante_id),
         participante_actualizado = Participante.unirse_a_equipo(participante, equipo.id),
         {:ok, _} <- RepositorioEquipos.actualizar(equipo_actualizado),
         {:ok, _} <- RepositorioParticipantes.actualizar(participante_actualizado) do
      {:ok, "#{participante.nombre} se ha unido al equipo #{equipo.nombre}"}
    else
      {:error, :no_encontrado} -> {:error, "Participante o equipo no encontrado"}
      {:error, :ya_es_integrante} -> {:error, "El participante ya está en este equipo"}
      {:error, :ya_tiene_equipo} -> {:error, "El participante ya está en otro equipo"}
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Cuenta cuántos equipos hay registrados.
  """
  def contar_equipos do
    RepositorioEquipos.contar()
  end

  @doc """
  Obtiene los equipos sin proyecto registrado.
  """
  def equipos_sin_proyecto do
    equipos = RepositorioEquipos.leer_todos()

    equipos
    |> Enum.filter(fn e -> is_nil(e.proyecto_id) end)
    |> Enum.map(fn e ->
      %{
        id: e.id,
        nombre: e.nombre,
        integrantes: length(e.integrantes)
      }
    end)
  end

  # ========== FUNCIONES PRIVADAS ==========

  # Verifica si existe un equipo con ese nombre
  defp equipo_existe?(nombre) do
    case RepositorioEquipos.obtener_por_nombre(nombre) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  # Obtiene un equipo por nombre o ID
  defp obtener_equipo(nombre_o_id) do
    # Intentar primero por nombre
    case RepositorioEquipos.obtener_por_nombre(nombre_o_id) do
      {:ok, equipo} -> {:ok, equipo}
      {:error, _} ->
        # Si falla, intentar por ID
        RepositorioEquipos.obtener_por_id(nombre_o_id)
    end
  end

  # Valida si un participante puede unirse a un equipo
  defp validar_puede_unirse(participante, equipo) do
    cond do
      Participante.tiene_equipo?(participante) and participante.equipo_id != equipo.id ->
        {:error, :ya_tiene_equipo}

      participante.id in equipo.integrantes ->
        {:error, :ya_es_integrante}

      true ->
        :ok
    end
  end
end
