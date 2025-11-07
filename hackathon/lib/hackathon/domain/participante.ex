defmodule Hackathon.Domain.Participante do
  @moduledoc """
  Representa un participante de la Hackathon.

  Puede ser: participante regular, mentor u organizador.
  """

  @enforce_keys [:id, :nombre, :correo]
  defstruct [
    :id,
    :nombre,
    :correo,
    rol: :participante,           # Por defecto es participante
    equipo_id: nil,               # nil hasta que se una a un equipo
    fecha_registro: nil
  ]

  @type rol :: :participante | :mentor | :organizador

  @type t :: %__MODULE__{
    id: String.t(),
    nombre: String.t(),
    correo: String.t(),
    rol: rol(),
    equipo_id: String.t() | nil,
    fecha_registro: DateTime.t() | nil
  }

  @doc """
  Crea un nuevo participante.

  ## Ejemplos
      iex> Participante.nuevo("123", "Juan Pérez", "juan@email.com")
      %Participante{id: "123", nombre: "Juan Pérez", ...}
  """
  def nuevo(id, nombre, correo, rol \\ :participante) do
    %__MODULE__{
      id: id,
      nombre: nombre,
      correo: correo,
      rol: rol,
      fecha_registro: DateTime.utc_now()
    }
  end

  @doc """
  Asigna el participante a un equipo.
  """
  def unirse_a_equipo(%__MODULE__{} = participante, equipo_id) do
    %{participante | equipo_id: equipo_id}
  end

  @doc """
  Verifica si el participante ya está en un equipo.
  """
  def tiene_equipo?(%__MODULE__{equipo_id: equipo_id}) do
    not is_nil(equipo_id)
  end

  @doc """
  Verifica si es un mentor.
  """
  def es_mentor?(%__MODULE__{rol: rol}), do: rol == :mentor

  @doc """
  Verifica si es organizador.
  """
  def es_organizador?(%__MODULE__{rol: rol}), do: rol == :organizador
end
