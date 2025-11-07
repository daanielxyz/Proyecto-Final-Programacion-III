defmodule Hackathon.Domain.Equipo do
  @moduledoc """
  Representa un equipo participante de la Hackathon.

  Campos:
  - id: Identificador único del equipo
  - nombre: Nombre del equipo (ej: "Los Crackers")
  - integrantes: Lista de IDs de los participantes
  - proyecto_id: ID del proyecto asociado (puede ser nil si no han registrado proyecto)
  - fecha_creacion: Cuándo se creó el equipo
  - estado: :activo o :inactivo
  """

  @enforce_keys [:id, :nombre]  # Campos obligatorios al crear
  defstruct [
    :id,
    :nombre,
    integrantes: [],              # Lista vacía por defecto
    proyecto_id: nil,             # nil hasta que registren proyecto
    fecha_creacion: nil,
    estado: :activo               # Por defecto está activo
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    nombre: String.t(),
    integrantes: list(String.t()),
    proyecto_id: String.t() | nil,
    fecha_creacion: DateTime.t() | nil,
    estado: :activo | :inactivo
  }

  @doc """
  Crea un nuevo equipo con los datos básicos.

  ## Ejemplos
      iex> Hackathon.Domain.Equipo.nuevo("123", "Los Crackers")
      %Hackathon.Domain.Equipo{id: "123", nombre: "Los Crackers", ...}
  """
  def nuevo(id, nombre, fecha_creacion \\ DateTime.utc_now()) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      fecha_creacion: fecha_creacion,
      estado: :activo
    }
  end

  @doc """
  Agrega un participante al equipo.
  """
  def agregar_integrante(%__MODULE__{} = equipo, participante_id) do
    if participante_id in equipo.integrantes do
      {:error, :ya_es_integrante}
    else
      {:ok, %{equipo | integrantes: [participante_id | equipo.integrantes]}}
    end
  end

  @doc """
  Asigna un proyecto al equipo.
  """
  def asignar_proyecto(%__MODULE__{} = equipo, proyecto_id) do
    %{equipo | proyecto_id: proyecto_id}
  end

  @doc """
  Verifica si el equipo tiene al menos un integrante.
  """
  def tiene_integrantes?(%__MODULE__{integrantes: integrantes}) do
    length(integrantes) > 0
  end
end
