defmodule Hackathon.Services.MentoriaService do
  @moduledoc """
  Service para gestionar el sistema de mentoría.

  Casos de uso:
  - Registrar mentores
  - Asignar mentores a equipos
  - Dar retroalimentación
  - Consultar mentores disponibles
  """

  alias Hackathon.Domain.{Mentor, Proyecto}
  alias Hackathon.Adapters.Persistencia.{RepositorioMentores, RepositorioEquipos, RepositorioProyectos}
  alias Hackathon.Core.Validaciones
  alias Hackathon.Utils.UuidHelper

  @doc """
  Registra un nuevo mentor en el sistema.

  ## Ejemplos
      iex> MentoriaService.registrar_mentor("Dr. García", "Inteligencia Artificial")
      {:ok, %Mentor{...}}
  """
  def registrar_mentor(nombre, especialidad) do
    cond do
      not Validaciones.nombre_valido?(nombre) ->
        {:error, "El nombre debe tener al menos 3 caracteres"}

      not Validaciones.texto_no_vacio?(especialidad) ->
        {:error, "La especialidad no puede estar vacía"}

      true ->
        id = UuidHelper.generar()
        mentor = Mentor.nuevo(id, nombre, especialidad)

        case RepositorioMentores.guardar(mentor) do
          {:ok, mentor} -> {:ok, mentor}
          {:error, razon} -> {:error, "Error al guardar: #{razon}"}
        end
    end
  end

  @doc """
  Asigna un mentor a un equipo.
  """
  def asignar_mentor_a_equipo(mentor_id, nombre_equipo) do
    with {:ok, mentor} <- RepositorioMentores.obtener_por_id(mentor_id),
         {:ok, equipo} <- RepositorioEquipos.obtener_por_nombre(nombre_equipo),
         true <- Mentor.disponible?(mentor) || {:error, "El mentor no está disponible"},
         {:ok, mentor_actualizado} <- Mentor.asignar_equipo(mentor, equipo.id),
         {:ok, _} <- RepositorioMentores.actualizar(mentor_actualizado) do
      {:ok, "Mentor #{mentor.nombre} asignado al equipo #{equipo.nombre}"}
    else
      {:error, :no_encontrado} -> {:error, "Mentor o equipo no encontrado"}
      {:error, :equipo_ya_asignado} -> {:error, "El mentor ya está asignado a este equipo"}
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  El mentor da retroalimentación a un equipo.
  """
  def dar_feedback(mentor_id, nombre_equipo, comentario) do
    cond do
      not Validaciones.texto_no_vacio?(comentario) ->
        {:error, "El comentario no puede estar vacío"}

      true ->
        with {:ok, mentor} <- RepositorioMentores.obtener_por_id(mentor_id),
             {:ok, equipo} <- RepositorioEquipos.obtener_por_nombre(nombre_equipo),
             true <- Mentor.asignado_a?(mentor, equipo.id) || {:error, "No estás asignado a este equipo"},
             {:ok, proyecto} <- RepositorioProyectos.obtener_por_equipo(equipo.id),
             proyecto_actualizado = Proyecto.agregar_feedback(proyecto, mentor_id, comentario),
             {:ok, _} <- RepositorioProyectos.actualizar(proyecto_actualizado) do
          {:ok, "Retroalimentación registrada"}
        else
          {:error, :no_encontrado} -> {:error, "Mentor, equipo o proyecto no encontrado"}
          {:error, razon} -> {:error, razon}
        end
    end
  end

  @doc """
  Lista todos los mentores registrados.
  """
  def listar_mentores do
    mentores = RepositorioMentores.leer_todos()

    mentores_info = Enum.map(mentores, fn m ->
      equipos_nombres = obtener_nombres_equipos(m.equipos_asignados)

      %{
        id: m.id,
        nombre: m.nombre,
        especialidad: m.especialidad,
        equipos_asignados: equipos_nombres,
        cantidad_equipos: length(m.equipos_asignados),
        disponible: m.disponible
      }
    end)

    {:ok, mentores_info}
  end

  @doc """
  Lista mentores disponibles para asignar.
  """
  def listar_mentores_disponibles do
    mentores = RepositorioMentores.obtener_disponibles()

    mentores_info = Enum.map(mentores, fn m ->
      %{
        id: m.id,
        nombre: m.nombre,
        especialidad: m.especialidad,
        equipos_actuales: length(m.equipos_asignados)
      }
    end)

    {:ok, mentores_info}
  end

  @doc """
  Busca mentores por especialidad.
  """
  def buscar_por_especialidad(especialidad) do
    mentores = RepositorioMentores.obtener_por_especialidad(especialidad)

    if Enum.empty?(mentores) do
      {:error, "No hay mentores con esa especialidad"}
    else
      mentores_info = Enum.map(mentores, fn m ->
        %{
          nombre: m.nombre,
          disponible: m.disponible,
          equipos: length(m.equipos_asignados)
        }
      end)

      {:ok, mentores_info}
    end
  end

  @doc """
  Obtiene el mentor asignado a un equipo.
  """
  def mentor_del_equipo(nombre_equipo) do
    case RepositorioEquipos.obtener_por_nombre(nombre_equipo) do
      {:ok, equipo} ->
        case RepositorioMentores.obtener_por_equipo(equipo.id) do
          {:ok, mentor} ->
            info = %{
              nombre: mentor.nombre,
              especialidad: mentor.especialidad,
              otros_equipos: length(mentor.equipos_asignados) - 1
            }
            {:ok, info}

          {:error, _} ->
            {:error, "Este equipo no tiene mentor asignado"}
        end

      {:error, _} ->
        {:error, "Equipo no encontrado"}
    end
  end

  @doc """
  Obtiene toda la retroalimentación que ha dado un mentor.
  """
  def retroalimentacion_de_mentor(mentor_id) do
    case RepositorioMentores.obtener_por_id(mentor_id) do
      {:ok, mentor} ->
        # Buscar todos los proyectos de los equipos asignados
        feedback_total = Enum.flat_map(mentor.equipos_asignados, fn equipo_id ->
          case RepositorioProyectos.obtener_por_equipo(equipo_id) do
            {:ok, proyecto} ->
              # Filtrar solo el feedback de este mentor
              proyecto.retroalimentacion
              |> Enum.filter(fn f -> f.mentor_id == mentor_id end)
              |> Enum.map(fn f ->
                nombre_equipo = case RepositorioEquipos.obtener_por_id(equipo_id) do
                  {:ok, eq} -> eq.nombre
                  _ -> "Equipo desconocido"
                end

                Map.put(f, :equipo, nombre_equipo)
              end)

            {:error, _} -> []
          end
        end)

        {:ok, feedback_total}

      {:error, _} ->
        {:error, "Mentor no encontrado"}
    end
  end

  @doc """
  Cuenta cuántos mentores hay registrados.
  """
  def contar_mentores do
    RepositorioMentores.contar()
  end

  @doc """
  Cuenta cuántos mentores están disponibles.
  """
  def contar_disponibles do
    RepositorioMentores.contar_disponibles()
  end

  # ========== FUNCIONES PRIVADAS ==========

  # Obtiene los nombres de los equipos dado una lista de IDs
  defp obtener_nombres_equipos(equipos_ids) do
    Enum.map(equipos_ids, fn id ->
      case RepositorioEquipos.obtener_por_id(id) do
        {:ok, equipo} -> equipo.nombre
        {:error, _} -> "Equipo desconocido"
      end
    end)
  end
end
