defmodule Hackathon.Adapters.Persistencia.RepositorioProyectos do
  @moduledoc """
  Repositorio para persistir proyectos en archivo JSON.

  Maneja estructuras complejas como avances y retroalimentación.
  """

  alias Hackathon.Domain.Proyecto

  @archivo "data/proyectos.json"

  def guardar(%Proyecto{} = proyecto) do
    proyectos = leer_todos()

    existe? = Enum.any?(proyectos, fn p -> p.id == proyecto.id end)

    if existe? do
      {:error, :proyecto_ya_existe}
    else
      nuevos = [proyecto | proyectos]
      guardar_todos(nuevos)
      {:ok, proyecto}
    end
  end

  def actualizar(%Proyecto{} = proyecto) do
    proyectos = leer_todos()

    actualizados = Enum.map(proyectos, fn p ->
      if p.id == proyecto.id, do: proyecto, else: p
    end)

    guardar_todos(actualizados)
    {:ok, proyecto}
  end

  def guardar_todos(proyectos) when is_list(proyectos) do
    File.mkdir_p!("data")

    proyectos_json = Enum.map(proyectos, &struct_a_mapa/1)
    contenido = Jason.encode!(proyectos_json, pretty: true)
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
        IO.puts("Error leyendo proyectos: #{inspect(razon)}")
        []
    end
  end

  def obtener_por_id(id) do
    proyectos = leer_todos()

    case Enum.find(proyectos, fn p -> p.id == id end) do
      nil -> {:error, :no_encontrado}
      proyecto -> {:ok, proyecto}
    end
  end

  def obtener_por_equipo(equipo_id) do
    case Enum.find(leer_todos(), fn p -> p.equipo_id == equipo_id end) do
      nil -> {:error, :no_encontrado}
      proyecto -> {:ok, proyecto}
    end
  end

  def obtener_por_categoria(categoria) do
    leer_todos()
    |> Enum.filter(fn p -> p.categoria == categoria end)
  end

  def obtener_por_estado(estado) do
    leer_todos()
    |> Enum.filter(fn p -> p.estado == estado end)
  end

  def eliminar(id) do
    proyectos = leer_todos()
    filtrados = Enum.reject(proyectos, fn p -> p.id == id end)

    if length(proyectos) == length(filtrados) do
      {:error, :no_encontrado}
    else
      guardar_todos(filtrados)
      :ok
    end
  end

  def contar, do: leer_todos() |> length()

  # ========== PRIVADAS ==========

  defp struct_a_mapa(%Proyecto{} = p) do
    %{
      id: p.id,
      equipo_id: p.equipo_id,
      titulo: p.titulo,
      descripcion: p.descripcion,
      categoria: p.categoria,
      estado: p.estado,
      avances: Enum.map(p.avances, &avance_a_mapa/1),
      retroalimentacion: Enum.map(p.retroalimentacion, &feedback_a_mapa/1),
      fecha_creacion: datetime_a_string(p.fecha_creacion)
    }
  end

  defp mapa_a_struct(mapa) do
    %Proyecto{
      id: mapa.id,
      equipo_id: mapa.equipo_id,
      titulo: mapa.titulo,
      descripcion: mapa.descripcion || "",
      categoria: mapa.categoria || "social",
      estado: mapa.estado || "idea",
      avances: Enum.map(mapa.avances || [], &mapa_a_avance/1),
      retroalimentacion: Enum.map(mapa.retroalimentacion || [], &mapa_a_feedback/1),
      fecha_creacion: string_a_datetime(mapa.fecha_creacion)
    }
  end

  # Convierte avance struct → mapa
  defp avance_a_mapa(avance) do
    %{
      texto: avance.texto,
      fecha: datetime_a_string(avance.fecha)
    }
  end

  # Convierte mapa → avance struct
  defp mapa_a_avance(mapa) do
    %{
      texto: mapa.texto,
      fecha: string_a_datetime(mapa.fecha)
    }
  end

  # Convierte feedback struct → mapa
  defp feedback_a_mapa(feedback) do
    %{
      mentor_id: feedback.mentor_id,
      comentario: feedback.comentario,
      fecha: datetime_a_string(feedback.fecha)
    }
  end

  # Convierte mapa → feedback struct
  defp mapa_a_feedback(mapa) do
    %{
      mentor_id: mapa.mentor_id,
      comentario: mapa.comentario,
      fecha: string_a_datetime(mapa.fecha)
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
