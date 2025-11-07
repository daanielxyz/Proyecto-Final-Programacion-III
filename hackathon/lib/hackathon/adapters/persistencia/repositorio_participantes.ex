defmodule Hackathon.Adapters.Persistencia.RepositorioParticipantes do
  @moduledoc """
  Repositorio para persistir participantes en archivo JSON.
  """

  alias Hackathon.Domain.Participante

  @archivo "data/participantes.json"

  def guardar(%Participante{} = participante) do
    participantes = leer_todos()

    existe? = Enum.any?(participantes, fn p -> p.id == participante.id end)

    if existe? do
      {:error, :participante_ya_existe}
    else
      nuevos = [participante | participantes]
      guardar_todos(nuevos)
      {:ok, participante}
    end
  end

  def actualizar(%Participante{} = participante) do
    participantes = leer_todos()

    actualizados = Enum.map(participantes, fn p ->
      if p.id == participante.id, do: participante, else: p
    end)

    guardar_todos(actualizados)
    {:ok, participante}
  end

  def guardar_todos(participantes) when is_list(participantes) do
    File.mkdir_p!("data")

    participantes_json = Enum.map(participantes, &struct_a_mapa/1)
    contenido = Jason.encode!(participantes_json, pretty: true)
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
        IO.puts("Error leyendo participantes: #{inspect(razon)}")
        []
    end
  end

  def obtener_por_id(id) do
    participantes = leer_todos()

    case Enum.find(participantes, fn p -> p.id == id end) do
      nil -> {:error, :no_encontrado}
      participante -> {:ok, participante}
    end
  end

  def obtener_por_correo(correo) do
    participantes = leer_todos()

    case Enum.find(participantes, fn p -> p.correo == correo end) do
      nil -> {:error, :no_encontrado}
      participante -> {:ok, participante}
    end
  end

  def obtener_por_equipo(equipo_id) do
    leer_todos()
    |> Enum.filter(fn p -> p.equipo_id == equipo_id end)
  end

  def eliminar(id) do
    participantes = leer_todos()
    filtrados = Enum.reject(participantes, fn p -> p.id == id end)

    if length(participantes) == length(filtrados) do
      {:error, :no_encontrado}
    else
      guardar_todos(filtrados)
      :ok
    end
  end

  def contar, do: leer_todos() |> length()

  # ========== PRIVADAS ==========

  defp struct_a_mapa(%Participante{} = p) do
    %{
      id: p.id,
      nombre: p.nombre,
      correo: p.correo,
      rol: Atom.to_string(p.rol),
      equipo_id: p.equipo_id,
      fecha_registro: datetime_a_string(p.fecha_registro)
    }
  end

  defp mapa_a_struct(mapa) do
    %Participante{
      id: mapa.id,
      nombre: mapa.nombre,
      correo: mapa.correo,
      rol: String.to_atom(mapa.rol || "participante"),
      equipo_id: mapa.equipo_id,
      fecha_registro: string_a_datetime(mapa.fecha_registro)
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
