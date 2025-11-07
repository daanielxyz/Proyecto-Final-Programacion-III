
defmodule Hackathon.Domain.Proyecto do
  @moduledoc """
  Representa el proyecto de un equipo en la Hackathon.

  Incluye la idea inicial, avances y retroalimentación de mentores.
  """

  @enforce_keys [:id, :equipo_id, :titulo]
  defstruct [
    :id,
    :equipo_id,
    :titulo,
    descripcion: "",
    categoria: "social",          # Por defecto
    estado: "idea",               # Por defecto empieza como idea
    avances: [],                  # Lista de mapas %{texto, fecha}
    retroalimentacion: [],        # Lista de mapas %{mentor_id, comentario, fecha}
    fecha_creacion: nil
  ]

  @type categoria :: String.t()  # "social" | "ambiental" | "educativo"
  @type estado :: String.t()     # "idea" | "desarrollo" | "finalizado"

  @type avance :: %{
    texto: String.t(),
    fecha: DateTime.t()
  }

  @type feedback :: %{
    mentor_id: String.t(),
    comentario: String.t(),
    fecha: DateTime.t()
  }

  @type t :: %__MODULE__{
    id: String.t(),
    equipo_id: String.t(),
    titulo: String.t(),
    descripcion: String.t(),
    categoria: categoria(),
    estado: estado(),
    avances: list(avance()),
    retroalimentacion: list(feedback()),
    fecha_creacion: DateTime.t() | nil
  }

  @doc """
  Crea un nuevo proyecto.

  ## Ejemplos
      iex> Proyecto.nuevo("p1", "e1", "App Educativa", "Una app para...", "educativo")
      %Proyecto{id: "p1", titulo: "App Educativa", ...}
  """
  def nuevo(id, equipo_id, titulo, descripcion, categoria) do
    %__MODULE__{
      id: id,
      equipo_id: equipo_id,
      titulo: titulo,
      descripcion: descripcion,
      categoria: categoria,
      estado: "idea",
      fecha_creacion: DateTime.utc_now()
    }
  end

  @doc """
  Agrega un avance al proyecto.
  """
  def agregar_avance(%__MODULE__{} = proyecto, texto) do
    avance = %{
      texto: texto,
      fecha: DateTime.utc_now()
    }

    %{proyecto | avances: [avance | proyecto.avances]}
  end

  @doc """
  Agrega retroalimentación de un mentor.
  """
  def agregar_feedback(%__MODULE__{} = proyecto, mentor_id, comentario) do
    feedback = %{
      mentor_id: mentor_id,
      comentario: comentario,
      fecha: DateTime.utc_now()
    }

    %{proyecto | retroalimentacion: [feedback | proyecto.retroalimentacion]}
  end

  @doc """
  Cambia el estado del proyecto.
  """
  def cambiar_estado(%__MODULE__{} = proyecto, nuevo_estado)
      when nuevo_estado in ["idea", "desarrollo", "finalizado"] do
    {:ok, %{proyecto | estado: nuevo_estado}}
  end
  def cambiar_estado(%__MODULE__{}, _), do: {:error, :estado_invalido}

  @doc """
  Verifica si el proyecto ha sido finalizado.
  """
  def finalizado?(%__MODULE__{estado: estado}), do: estado == "finalizado"
end
