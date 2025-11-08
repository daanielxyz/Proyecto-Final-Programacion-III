defmodule Hackathon.Adapters.Persistencia.RepositorioMentores do
  @moduledoc """
  Repositorio para persistir mentores en archivo JSON.
  """

  alias Hackathon.Domain.Mentor

  @archivo "data/mentores.json"

  def guardar(%Mentor{} = mentor) do
    mentores = leer_todos()

    existe? = Enum.any?(mentores, fn m -> m.id == mentor.id end)

    if existe? do
      {:error, :mentor_ya_existe}
    else
      nuevos = [mentor | mentores]
      guardar_todos(nuevos)
      {:ok, mentor}
    end
  end

  def actualizar(%Mentor{} = mentor) do
    mentores = leer_todos()

    actualizados = Enum.map(mentores, fn m ->
      if m.id == mentor.id, do: mentor, else: m
    end)

    guardar_todos(actualizados)
    {:ok, mentor}
  end

  def guardar_todos(mentores) when is_list(mentores) do
    File.mkdir_p!("data")

    mentores_json = Enum.map(mentores, &struct_a_mapa/1)
    contenido = Jason.encode!(mentores_json, pretty: true)
    File.write!(@archivo, contenido)
    :ok
  end

  def leer_todos do
    case File.read(@archivo) do
      {:ok, contenido} ->
        contenido
        |> Jason.decode!(keys: :atoms)
        |> Enum.map(&mapa_a_struct/1)

      {:error, :enoent} -> []
      {:error, razon} ->
        IO.puts("Error leyendo mentores: #{inspect(razon)}")
        []
    end
  end

  def obtener_por_id(id) do
    mentores = leer_todos()

    case Enum.find(mentores, fn m -> m.id == id end) do
      nil -> {:error, :no_encontrado}
      mentor -> {:ok, mentor}
    end
  end

  @doc """
  Obtiene mentores disponibles (que pueden aceptar más equipos).
  """
  def obtener_disponibles do
    leer_todos()
    |> Enum.filter(fn m -> m.disponible end)
  end

  @doc """
  Obtiene mentores por especialidad.
  """
  def obtener_por_especialidad(especialidad) do
    leer_todos()
    |> Enum.filter(fn m ->
      String.downcase(m.especialidad) == String.downcase(especialidad)
    end)
  end

  @doc """
  Obtiene el mentor asignado a un equipo específico.
  """
  def obtener_por_equipo(equipo_id) do
    case Enum.find(leer_todos(), fn m -> equipo_id in m.equipos_asignados end) do
      nil -> {:error, :no_encontrado}
      mentor -> {:ok, mentor}
    end
  end

  def eliminar(id) do
    mentores = leer_todos()
    filtrados = Enum.reject(mentores, fn m -> m.id == id end)

    if length(mentores) == length(filtrados) do
      {:error, :no_encontrado}
    else
      guardar_todos(filtrados)
      :ok
    end
  end

  def contar, do: leer_todos() |> length()

  @doc """
  Cuenta cuántos mentores están disponibles.
  """
  def contar_disponibles do
    obtener_disponibles() |> length()
  end

  # ========== PRIVADAS ==========

  defp struct_a_mapa(%Mentor{} = m) do
    %{
      id: m.id,
      nombre: m.nombre,
      especialidad: m.especialidad,
      equipos_asignados: m.equipos_asignados,
      disponible: m.disponible
    }
  end

  defp mapa_a_struct(mapa) do
    %Mentor{
      id: mapa.id,
      nombre: mapa.nombre,
      especialidad: mapa.especialidad,
      equipos_asignados: mapa.equipos_asignados || [],
      disponible: mapa.disponible || true
    }
  end
end
