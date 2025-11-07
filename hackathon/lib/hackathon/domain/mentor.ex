defmodule Hackathon.Domain.Mentor do
  @moduledoc """
  Representa un mentor de la Hackathon.

  Los mentores pueden ser asignados a equipos y dar retroalimentación.
  """

  @enforce_keys [:id, :nombre, :especialidad]
  defstruct [
    :id,
    :nombre,
    :especialidad,
    equipos_asignados: [],       # Lista de IDs de equipos
    disponible: true             # Si está disponible para más equipos
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    nombre: String.t(),
    especialidad: String.t(),
    equipos_asignados: list(String.t()),
    disponible: boolean()
  }

  @doc """
  Crea un nuevo mentor.

  ## Ejemplos
      iex> Mentor.nuevo("m1", "Dr. García", "Inteligencia Artificial")
      %Mentor{id: "m1", nombre: "Dr. García", ...}
  """
  def nuevo(id, nombre, especialidad) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      especialidad: especialidad,
      disponible: true
    }
  end

  @doc """
  Asigna el mentor a un equipo.
  """
  def asignar_equipo(%__MODULE__{} = mentor, equipo_id) do
    if equipo_id in mentor.equipos_asignados do
      {:error, :equipo_ya_asignado}
    else
      nuevo_mentor = %{mentor | equipos_asignados: [equipo_id | mentor.equipos_asignados]}

      # Si tiene 3+ equipos, marcar como no disponible
      disponible = length(nuevo_mentor.equipos_asignados) < 3
      {:ok, %{nuevo_mentor | disponible: disponible}}
    end
  end

  @doc """
  Verifica si el mentor está disponible para nuevos equipos.
  """
  def disponible?(%__MODULE__{disponible: disponible}), do: disponible

  @doc """
  Verifica si el mentor está asignado a un equipo específico.
  """
  def asignado_a?(%__MODULE__{equipos_asignados: equipos}, equipo_id) do
    equipo_id in equipos
  end

  @doc """
  Cuenta cuántos equipos tiene asignados.
  """
  def cantidad_equipos(%__MODULE__{equipos_asignados: equipos}) do
    length(equipos)
  end
end
