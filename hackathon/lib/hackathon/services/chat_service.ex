defmodule Hackathon.Services.ChatService do
  @moduledoc """
  Service para gestionar el sistema de chat.

  Casos de uso:
  - Enviar mensajes a equipos
  - Ver historial de chat
  - Enviar anuncios generales
  - Ver últimos mensajes
  """

  alias Hackathon.Domain.Mensaje
  alias Hackathon.Adapters.Persistencia.{RepositorioMensajes, RepositorioParticipantes, RepositorioEquipos}
  alias Hackathon.Core.Validaciones
  alias Hackathon.Utils.{UuidHelper, FechaHelper}

  @doc """
  Envía un mensaje de un participante a su equipo.

  ## Ejemplos
      iex> ChatService.enviar_mensaje("p1", "Hola equipo!")
      {:ok, "Mensaje enviado"}
  """
  def enviar_mensaje(participante_id, contenido) do
    cond do
      not Validaciones.texto_no_vacio?(contenido) ->
        {:error, "El mensaje no puede estar vacío"}

      true ->
        case RepositorioParticipantes.obtener_por_id(participante_id) do
          {:ok, participante} ->
            if participante.equipo_id do
              # Crear y guardar mensaje
              id = UuidHelper.generar()
              mensaje = Mensaje.nuevo(id, participante_id, participante.equipo_id, contenido)

              RepositorioMensajes.guardar(mensaje)
              {:ok, "Mensaje enviado"}
            else
              {:error, "Debes estar en un equipo para enviar mensajes"}
            end

          {:error, _} ->
            {:error, "Participante no encontrado"}
        end
    end
  end

  @doc """
  Envía un anuncio general visible para todos.
  Solo organizadores pueden enviar anuncios.
  """
  def enviar_anuncio(participante_id, contenido) do
    cond do
      not Validaciones.texto_no_vacio?(contenido) ->
        {:error, "El anuncio no puede estar vacío"}

      true ->
        case RepositorioParticipantes.obtener_por_id(participante_id) do
          {:ok, participante} ->
            if participante.rol == :organizador do
              id = UuidHelper.generar()
              anuncio = Mensaje.anuncio(id, participante_id, contenido)

              RepositorioMensajes.guardar(anuncio)
              {:ok, "Anuncio publicado"}
            else
              {:error, "Solo los organizadores pueden enviar anuncios"}
            end

          {:error, _} ->
            {:error, "Participante no encontrado"}
        end
    end
  end

  @doc """
  Obtiene el historial de chat de un equipo.
  Incluye nombre del emisor en cada mensaje.
  """
  def ver_chat(nombre_equipo, limite \\ 50) do
    case RepositorioEquipos.obtener_por_nombre(nombre_equipo) do
      {:ok, equipo} ->
        mensajes = RepositorioMensajes.obtener_ultimos(equipo.id, limite)

        # Enriquecer mensajes con nombre del emisor
        mensajes_enriquecidos = Enum.map(mensajes, fn msg ->
          nombre_emisor = case RepositorioParticipantes.obtener_por_id(msg.emisor_id) do
            {:ok, p} -> p.nombre
            {:error, _} -> "Usuario desconocido"
          end

          %{
            id: msg.id,
            emisor: nombre_emisor,
            contenido: msg.contenido,
            hora: FechaHelper.formatear_corto(msg.timestamp),
            timestamp: msg.timestamp
          }
        end)

        {:ok, mensajes_enriquecidos}

      {:error, _} ->
        {:error, "Equipo no encontrado"}
    end
  end

  @doc """
  Obtiene todos los anuncios generales.
  """
  def ver_anuncios(limite \\ 20) do
    anuncios = RepositorioMensajes.obtener_anuncios()
    |> Enum.take(limite)

    anuncios_info = Enum.map(anuncios, fn msg ->
      nombre_emisor = case RepositorioParticipantes.obtener_por_id(msg.emisor_id) do
        {:ok, p} -> p.nombre
        {:error, _} -> "Sistema"
      end

      %{
        emisor: nombre_emisor,
        contenido: msg.contenido,
        fecha: FechaHelper.formatear(msg.timestamp)
      }
    end)

    {:ok, anuncios_info}
  end

  @doc """
  Obtiene estadísticas del chat de un equipo.
  """
  def estadisticas_equipo(nombre_equipo) do
    case RepositorioEquipos.obtener_por_nombre(nombre_equipo) do
      {:ok, equipo} ->
        total_mensajes = RepositorioMensajes.contar_por_equipo(equipo.id)

        # Contar mensajes por participante
        mensajes = RepositorioMensajes.obtener_por_equipo(equipo.id)

        mensajes_por_participante = mensajes
        |> Enum.group_by(& &1.emisor_id)
        |> Enum.map(fn {emisor_id, msgs} ->
          nombre = case RepositorioParticipantes.obtener_por_id(emisor_id) do
            {:ok, p} -> p.nombre
            {:error, _} -> "Desconocido"
          end

          %{nombre: nombre, cantidad: length(msgs)}
        end)
        |> Enum.sort_by(& &1.cantidad, :desc)

        stats = %{
          equipo: equipo.nombre,
          total_mensajes: total_mensajes,
          mensajes_por_participante: mensajes_por_participante
        }

        {:ok, stats}

      {:error, _} ->
        {:error, "Equipo no encontrado"}
    end
  end

  @doc """
  Busca mensajes que contengan un texto específico en un equipo.
  """
  def buscar_mensajes(nombre_equipo, texto_busqueda) do
    case RepositorioEquipos.obtener_por_nombre(nombre_equipo) do
      {:ok, equipo} ->
        mensajes = RepositorioMensajes.obtener_por_equipo(equipo.id)

        resultados = mensajes
        |> Enum.filter(fn msg ->
          String.contains?(
            String.downcase(msg.contenido),
            String.downcase(texto_busqueda)
          )
        end)
        |> Enum.map(fn msg ->
          nombre_emisor = case RepositorioParticipantes.obtener_por_id(msg.emisor_id) do
            {:ok, p} -> p.nombre
            {:error, _} -> "Desconocido"
          end

          %{
            emisor: nombre_emisor,
            contenido: msg.contenido,
            fecha: FechaHelper.formatear(msg.timestamp)
          }
        end)

        {:ok, resultados}

      {:error, _} ->
        {:error, "Equipo no encontrado"}
    end
  end
end
