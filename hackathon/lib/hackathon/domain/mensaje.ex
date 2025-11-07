defmodule Hackathon.Domain.Mensaje do
  @moduledoc """
  Representa un mensaje en el sistema de chat.

  Puede ser un mensaje normal de equipo, un anuncio general,
  o un mensaje del sistema.
  """

  @enforce_keys [:id, :emisor_id, :contenido]
  defstruct [
    :id,
    :emisor_id,
    :contenido,
    equipo_id: nil,              # nil para mensajes generales
    timestamp: nil,
    tipo: :normal                # :normal | :anuncio | :sistema
  ]

  @type tipo :: :normal | :anuncio | :sistema

  @type t :: %__MODULE__{
    id: String.t(),
    emisor_id: String.t(),
    equipo_id: String.t() | nil,
    contenido: String.t(),
    timestamp: DateTime.t() | nil,
    tipo: tipo()
  }

  @doc """
  Crea un mensaje normal de equipo.

  ## Ejemplos
      iex> Mensaje.nuevo("m1", "user123", "equipo1", "Hola equipo!")
      %Mensaje{id: "m1", contenido: "Hola equipo!", ...}
  """
  def nuevo(id, emisor_id, equipo_id, contenido) do
    %__MODULE__{
      id: id,
      emisor_id: emisor_id,
      equipo_id: equipo_id,
      contenido: contenido,
      timestamp: DateTime.utc_now(),
      tipo: :normal
    }
  end

  @doc """
  Crea un anuncio general (visible para todos).
  """
  def anuncio(id, emisor_id, contenido) do
    %__MODULE__{
      id: id,
      emisor_id: emisor_id,
      equipo_id: nil,              # nil = general
      contenido: contenido,
      timestamp: DateTime.utc_now(),
      tipo: :anuncio
    }
  end

  @doc """
  Crea un mensaje del sistema.
  """
  def sistema(id, contenido) do
    %__MODULE__{
      id: id,
      emisor_id: "sistema",
      equipo_id: nil,
      contenido: contenido,
      timestamp: DateTime.utc_now(),
      tipo: :sistema
    }
  end

  @doc """
  Verifica si el mensaje es un anuncio general.
  """
  def es_anuncio?(%__MODULE__{tipo: tipo}), do: tipo == :anuncio

  @doc """
  Verifica si el mensaje pertenece a un equipo específico.
  """
  def de_equipo?(%__MODULE__{equipo_id: equipo_id}, equipo_id_buscado) do
    equipo_id == equipo_id_buscado
  end
end
