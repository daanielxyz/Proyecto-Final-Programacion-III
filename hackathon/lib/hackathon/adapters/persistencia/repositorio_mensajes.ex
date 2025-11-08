defmodule Hackathon.Adapters.Persistencia.RepositorioMensajes do
  @moduledoc """
  Repositorio para persistir mensajes del chat en archivo JSON.

  Maneja tanto mensajes de equipos como anuncios generales.
  """

  alias Hackathon.Domain.Mensaje

  @archivo "data/mensajes.json"

  def guardar(%Mensaje{} = mensaje) do
    mensajes = leer_todos()
    nuevos = [mensaje | mensajes]
    guardar_todos(nuevos)
    {:ok, mensaje}
  end

  def guardar_todos(mensajes) when is_list(mensajes) do
    File.mkdir_p!("data")

    mensajes_json = Enum.map(mensajes, &struct_a_mapa/1)
    contenido = Jason.encode!(mensajes_json, pretty: true)
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
        IO.puts("Error leyendo mensajes: #{inspect(razon)}")
        []
    end
  end

  @doc """
  Obtiene todos los mensajes de un equipo específico.
  Retorna los mensajes ordenados por fecha (más recientes primero).
  """
  def obtener_por_equipo(equipo_id) do
    leer_todos()
    |> Enum.filter(fn m -> m.equipo_id == equipo_id end)
    |> Enum.sort_by(& &1.timestamp, {:desc, DateTime})
  end

  @doc """
  Obtiene todos los anuncios generales (mensajes sin equipo_id).
  """
  def obtener_anuncios do
    leer_todos()
    |> Enum.filter(fn m -> m.tipo == :anuncio end)
    |> Enum.sort_by(& &1.timestamp, {:desc, DateTime})
  end

  @doc """
  Obtiene los últimos N mensajes de un equipo.
  """
  def obtener_ultimos(equipo_id, cantidad \\ 50) do
    obtener_por_equipo(equipo_id)
    |> Enum.take(cantidad)
  end

  @doc """
  Obtiene mensajes de un equipo desde una fecha específica.
  """
  def obtener_desde(equipo_id, fecha_desde) do
    obtener_por_equipo(equipo_id)
    |> Enum.filter(fn m ->
      DateTime.compare(m.timestamp, fecha_desde) in [:gt, :eq]
    end)
  end

  @doc """
  Elimina todos los mensajes de un equipo (útil al eliminar equipo).
  """
  def eliminar_por_equipo(equipo_id) do
    mensajes = leer_todos()
    filtrados = Enum.reject(mensajes, fn m -> m.equipo_id == equipo_id end)
    guardar_todos(filtrados)
    :ok
  end

  @doc """
  Cuenta cuántos mensajes hay en total.
  """
  def contar, do: leer_todos() |> length()

  @doc """
  Cuenta cuántos mensajes tiene un equipo.
  """
  def contar_por_equipo(equipo_id) do
    obtener_por_equipo(equipo_id) |> length()
  end

  # ========== PRIVADAS ==========

  defp struct_a_mapa(%Mensaje{} = m) do
    %{
      id: m.id,
      emisor_id: m.emisor_id,
      equipo_id: m.equipo_id,
      contenido: m.contenido,
      timestamp: datetime_a_string(m.timestamp),
      tipo: Atom.to_string(m.tipo)
    }
  end

  defp mapa_a_struct(mapa) do
    %Mensaje{
      id: mapa.id,
      emisor_id: mapa.emisor_id,
      equipo_id: mapa.equipo_id,
      contenido: mapa.contenido,
      timestamp: string_a_datetime(mapa.timestamp),
      tipo: String.to_atom(mapa.tipo || "normal")
    }
  end

  defp datetime_a_string(nil), do: nil
  defp datetime_a_string(datetime), do: DateTime.to_iso8601(datetime)

  defp string_a_datetime(nil), do: nil
  defp string_a_datetime(string) do
    case DateTime.from_iso8601(string) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end
end
