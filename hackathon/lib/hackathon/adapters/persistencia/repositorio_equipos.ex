defmodule Hackathon.Adapters.Persistencia.RepositorioEquipos do
  @moduledoc """
  Repositorio para persistir equipos en archivo JSON.

  Maneja todas las operaciones de lectura/escritura de equipos.
  """

  alias Hackathon.Domain.Equipo

  @archivo "data/equipos.json"

  @doc """
  Guarda un equipo nuevo (lo agrega a la lista existente).

  ## Ejemplos
      iex> equipo = Equipo.nuevo("123", "Los Crackers")
      iex> RepositorioEquipos.guardar(equipo)
      :ok
  """
  def guardar(%Equipo{} = equipo) do
    equipos = leer_todos()

    # Verificar si ya existe
    existe? = Enum.any?(equipos, fn e -> e.id == equipo.id end)

    if existe? do
      {:error, :equipo_ya_existe}
    else
      nuevos_equipos = [equipo | equipos]
      guardar_todos(nuevos_equipos)
      {:ok, equipo}
    end
  end

  @doc """
  Actualiza un equipo existente.
  """
  def actualizar(%Equipo{} = equipo) do
    equipos = leer_todos()

    equipos_actualizados = Enum.map(equipos, fn e ->
      if e.id == equipo.id, do: equipo, else: e
    end)

    guardar_todos(equipos_actualizados)
    {:ok, equipo}
  end

  @doc """
  Guarda la lista completa de equipos (sobrescribe el archivo).
  """
  def guardar_todos(equipos) when is_list(equipos) do
    # Asegurar que la carpeta data/ exista
    File.mkdir_p!("data")

    # Convertir structs a mapas para JSON
    equipos_json = Enum.map(equipos, &struct_a_mapa/1)

    # Escribir JSON bonito (con indentación)
    contenido = Jason.encode!(equipos_json, pretty: true)
    File.write!(@archivo, contenido)
    :ok
  end

  @doc """
  Lee todos los equipos del archivo.
  Retorna una lista vacía si el archivo no existe.
  """
  def leer_todos do
    case File.read(@archivo) do
      {:ok, contenido} ->
        contenido
        |> Jason.decode!(keys: :atoms)
        |> Enum.map(&mapa_a_struct/1)

      {:error, :enoent} ->
        # Archivo no existe, retornar lista vacía
        []

      {:error, razon} ->
        IO.puts("Error leyendo equipos: #{inspect(razon)}")
        []
    end
  end

  @doc """
  Busca un equipo por su ID.
  """
  def obtener_por_id(id) do
    equipos = leer_todos()

    case Enum.find(equipos, fn e -> e.id == id end) do
      nil -> {:error, :no_encontrado}
      equipo -> {:ok, equipo}
    end
  end

  @doc """
  Busca un equipo por su nombre.
  """
  def obtener_por_nombre(nombre) do
    equipos = leer_todos()

    case Enum.find(equipos, fn e -> e.nombre == nombre end) do
      nil -> {:error, :no_encontrado}
      equipo -> {:ok, equipo}
    end
  end

  @doc """
  Elimina un equipo por su ID.
  """
  def eliminar(id) do
    equipos = leer_todos()
    equipos_filtrados = Enum.reject(equipos, fn e -> e.id == id end)

    if length(equipos) == length(equipos_filtrados) do
      {:error, :no_encontrado}
    else
      guardar_todos(equipos_filtrados)
      :ok
    end
  end

  @doc """
  Cuenta cuántos equipos hay registrados.
  """
  def contar do
    leer_todos() |> length()
  end

  # ========== FUNCIONES PRIVADAS ==========

  # Convierte un struct Equipo a un mapa (para guardar en JSON)
  defp struct_a_mapa(%Equipo{} = equipo) do
    %{
      id: equipo.id,
      nombre: equipo.nombre,
      integrantes: equipo.integrantes,
      proyecto_id: equipo.proyecto_id,
      fecha_creacion: datetime_a_string(equipo.fecha_creacion),
      estado: Atom.to_string(equipo.estado)
    }
  end

  # Convierte un mapa (del JSON) a struct Equipo
  defp mapa_a_struct(mapa) do
    %Equipo{
      id: mapa.id,
      nombre: mapa.nombre,
      integrantes: mapa.integrantes || [],
      proyecto_id: mapa.proyecto_id,
      fecha_creacion: string_a_datetime(mapa.fecha_creacion),
      estado: String.to_atom(mapa.estado || "activo")
    }
  end

  # Convierte DateTime a string para JSON
  defp datetime_a_string(nil), do: nil
  defp datetime_a_string(datetime) do
    DateTime.to_iso8601(datetime)
  end

  # Convierte string a DateTime
  defp string_a_datetime(nil), do: nil
  defp string_a_datetime(string) do
    case DateTime.from_iso8601(string) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end
end
