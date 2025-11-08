defmodule Hackathon.Services.GestionProyectos do
  @moduledoc """
  Service para gestionar proyectos de la Hackathon.

  Casos de uso:
  - Registrar proyectos
  - Actualizar avances
  - Ver proyectos por categoría/estado
  - Cambiar estado del proyecto
  """

  alias Hackathon.Domain.Proyecto
  alias Hackathon.Adapters.Persistencia.{RepositorioProyectos, RepositorioEquipos}
  alias Hackathon.Core.Validaciones
  alias Hackathon.Utils.UuidHelper

  @doc """
  Registra un nuevo proyecto para un equipo.

  ## Ejemplos
      iex> GestionProyectos.registrar_proyecto("e1", "App Educativa", "Una app...", "educativo")
      {:ok, %Proyecto{...}}
  """
  def registrar_proyecto(equipo_id, titulo, descripcion, categoria) do
    # 1. Validar
    cond do
      not Validaciones.texto_no_vacio?(titulo) ->
        {:error, "El título no puede estar vacío"}

      not Validaciones.texto_no_vacio?(descripcion) ->
        {:error, "La descripción no puede estar vacía"}

      not Validaciones.categoria_proyecto_valida?(categoria) ->
        {:error, "Categoría inválida. Debe ser: social, ambiental o educativo"}

      not equipo_existe?(equipo_id) ->
        {:error, "El equipo no existe"}

      equipo_ya_tiene_proyecto?(equipo_id) ->
        {:error, "El equipo ya tiene un proyecto registrado"}

      true ->
        # 2. Crear proyecto
        id = UuidHelper.generar()
        proyecto = Proyecto.nuevo(id, equipo_id, titulo, descripcion, categoria)

        # 3. Guardar proyecto
        with {:ok, proyecto} <- RepositorioProyectos.guardar(proyecto),
             {:ok, equipo} <- RepositorioEquipos.obtener_por_id(equipo_id),
             equipo_actualizado = Hackathon.Domain.Equipo.asignar_proyecto(equipo, proyecto.id),
             {:ok, _} <- RepositorioEquipos.actualizar(equipo_actualizado) do
          {:ok, proyecto}
        else
          {:error, razon} -> {:error, "Error al guardar: #{razon}"}
        end
    end
  end

  @doc """
  Actualiza el avance de un proyecto.
  """
  def actualizar_avance(equipo_id, texto_avance) do
    cond do
      not Validaciones.texto_no_vacio?(texto_avance) ->
        {:error, "El avance no puede estar vacío"}

      true ->
        case RepositorioProyectos.obtener_por_equipo(equipo_id) do
          {:ok, proyecto} ->
            proyecto_actualizado = Proyecto.agregar_avance(proyecto, texto_avance)
            RepositorioProyectos.actualizar(proyecto_actualizado)
            {:ok, "Avance registrado correctamente"}

          {:error, _} ->
            {:error, "El equipo no tiene un proyecto registrado"}
        end
    end
  end

  @doc """
  Cambia el estado de un proyecto.
  """
  def cambiar_estado(equipo_id, nuevo_estado) do
    case RepositorioProyectos.obtener_por_equipo(equipo_id) do
      {:ok, proyecto} ->
        case Proyecto.cambiar_estado(proyecto, nuevo_estado) do
          {:ok, proyecto_actualizado} ->
            RepositorioProyectos.actualizar(proyecto_actualizado)
            {:ok, "Estado actualizado a: #{nuevo_estado}"}

          {:error, :estado_invalido} ->
            {:error, "Estado inválido. Debe ser: idea, desarrollo o finalizado"}
        end

      {:error, _} ->
        {:error, "Proyecto no encontrado"}
    end
  end

  @doc """
  Obtiene información detallada de un proyecto.
  """
  def ver_proyecto(nombre_equipo) do
    with {:ok, equipo} <- RepositorioEquipos.obtener_por_nombre(nombre_equipo),
         {:ok, proyecto} <- RepositorioProyectos.obtener_por_equipo(equipo.id) do

      detalle = %{
        id: proyecto.id,
        equipo: equipo.nombre,
        titulo: proyecto.titulo,
        descripcion: proyecto.descripcion,
        categoria: proyecto.categoria,
        estado: proyecto.estado,
        cantidad_avances: length(proyecto.avances),
        avances: proyecto.avances,
        cantidad_feedback: length(proyecto.retroalimentacion),
        retroalimentacion: proyecto.retroalimentacion,
        fecha_creacion: proyecto.fecha_creacion
      }

      {:ok, detalle}
    else
      {:error, :no_encontrado} -> {:error, "Equipo o proyecto no encontrado"}
      {:error, razon} -> {:error, razon}
    end
  end

  @doc """
  Lista todos los proyectos.
  """
  def listar_proyectos do
    proyectos = RepositorioProyectos.leer_todos()

    proyectos_con_info = Enum.map(proyectos, fn p ->
      nombre_equipo = case RepositorioEquipos.obtener_por_id(p.equipo_id) do
        {:ok, equipo} -> equipo.nombre
        {:error, _} -> "Equipo desconocido"
      end

      %{
        id: p.id,
        equipo: nombre_equipo,
        titulo: p.titulo,
        categoria: p.categoria,
        estado: p.estado,
        avances: length(p.avances),
        feedback: length(p.retroalimentacion)
      }
    end)

    {:ok, proyectos_con_info}
  end

  @doc """
  Obtiene proyectos por categoría.
  """
  def proyectos_por_categoria(categoria) do
    if Validaciones.categoria_proyecto_valida?(categoria) do
      proyectos = RepositorioProyectos.obtener_por_categoria(categoria)

      proyectos_info = Enum.map(proyectos, fn p ->
        %{
          titulo: p.titulo,
          estado: p.estado,
          descripcion: p.descripcion
        }
      end)

      {:ok, proyectos_info}
    else
      {:error, "Categoría inválida"}
    end
  end

  @doc """
  Obtiene proyectos por estado.
  """
  def proyectos_por_estado(estado) do
    if Validaciones.estado_proyecto_valido?(estado) do
      proyectos = RepositorioProyectos.obtener_por_estado(estado)

      proyectos_info = Enum.map(proyectos, fn p ->
        %{
          titulo: p.titulo,
          categoria: p.categoria,
          descripcion: p.descripcion
        }
      end)

      {:ok, proyectos_info}
    else
      {:error, "Estado inválido"}
    end
  end

  @doc """
  Cuenta cuántos proyectos hay registrados.
  """
  def contar_proyectos do
    RepositorioProyectos.contar()
  end

  # ========== FUNCIONES PRIVADAS ==========

  defp equipo_existe?(equipo_id) do
    case RepositorioEquipos.obtener_por_id(equipo_id) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end

  defp equipo_ya_tiene_proyecto?(equipo_id) do
    case RepositorioProyectos.obtener_por_equipo(equipo_id) do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
