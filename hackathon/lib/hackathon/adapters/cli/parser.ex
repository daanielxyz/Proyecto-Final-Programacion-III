defmodule Hackathon.Adapters.CLI.Parser do
  @moduledoc """
  Parser para interpretar comandos de la CLI.

  Convierte entrada del usuario en comandos estructurados.
  """

  @doc """
  Parsea una línea de entrada y retorna un comando estructurado.

  ## Ejemplos
      iex> Parser.parsear("/teams")
      {:listar_equipos}

      iex> Parser.parsear("/join Los Crackers")
      {:unirse_equipo, "Los Crackers"}
  """
  def parsear(entrada) do
    entrada
    |> String.trim()
    |> parsear_comando()
  end

  # ========== COMANDOS PRINCIPALES ==========

  # /help - Muestra ayuda
  defp parsear_comando("/help"), do: {:ayuda}
  defp parsear_comando("help"), do: {:ayuda}
  defp parsear_comando("?"), do: {:ayuda}

  # /exit o /quit - Salir
  defp parsear_comando("/exit"), do: {:salir}
  defp parsear_comando("/quit"), do: {:salir}
  defp parsear_comando("exit"), do: {:salir}
  defp parsear_comando("quit"), do: {:salir}

  # /clear - Limpiar pantalla
  defp parsear_comando("/clear"), do: {:limpiar}
  defp parsear_comando("clear"), do: {:limpiar}

  # ========== GESTIÓN DE EQUIPOS ==========

  # /teams - Listar equipos
  defp parsear_comando("/teams"), do: {:listar_equipos}

  # /teams create <nombre> - Crear equipo
  defp parsear_comando("/teams create " <> nombre) when nombre != "" do
    {:crear_equipo, String.trim(nombre)}
  end

  # /team <nombre> - Ver detalle de equipo
  defp parsear_comando("/team " <> nombre) when nombre != "" do
    {:ver_equipo, String.trim(nombre)}
  end

  # /join <equipo> - Unirse a equipo
  defp parsear_comando("/join " <> equipo) when equipo != "" do
    {:unirse_equipo, String.trim(equipo)}
  end

  # ========== GESTIÓN DE PARTICIPANTES ==========

  # /register <nombre> <correo> - Registrarse
  defp parsear_comando("/register " <> args) do
    case String.split(args, " ", parts: 2) do
      [nombre, correo] -> {:registrar_participante, String.trim(nombre), String.trim(correo)}
      _ -> {:error, "Uso: /register <nombre> <correo>"}
    end
  end

  # /participants - Listar participantes
  defp parsear_comando("/participants"), do: {:listar_participantes}

  # /me <correo> - Ver mi información
  defp parsear_comando("/me " <> correo) when correo != "" do
    {:ver_participante, String.trim(correo)}
  end

  # Parsea el comando
  defp parsear_comando("/register-organizer " <> args) do
    case String.split(args, " ", parts: 2) do
      [nombre, correo] -> {:registrar_organizador, String.trim(nombre), String.trim(correo)}
      _ -> {:error, "Uso: /register-organizer <nombre> <correo>"}
    end
  end

  # ========== GESTIÓN DE PROYECTOS ==========

  # /project <equipo> - Ver proyecto de un equipo
  defp parsear_comando("/project " <> equipo) when equipo != "" do
    {:ver_proyecto, String.trim(equipo)}
  end

  # /projects - Listar todos los proyectos
  defp parsear_comando("/projects"), do: {:listar_proyectos}

  # /register-project <equipo> | <titulo> | <descripcion> | <categoria>
  defp parsear_comando("/register-project " <> args) do
    case String.split(args, "|") do
      [equipo, titulo, descripcion, categoria] ->
        {:registrar_proyecto, String.trim(equipo), String.trim(titulo), String.trim(descripcion),
         String.trim(categoria)}

      _ ->
        {:error, "Uso: /register-project <equipo> | <titulo> | <descripcion> | <categoria>"}
    end
  end

  # /progress <equipo> | <texto> - Actualizar avance
  defp parsear_comando("/progress " <> args) do
    case String.split(args, "|", parts: 2) do
      [equipo, texto] -> {:actualizar_avance, String.trim(equipo), String.trim(texto)}
      _ -> {:error, "Uso: /progress <equipo> | <texto del avance>"}
    end
  end

  # ========== CHAT ==========

  # /chat <equipo> - Ver chat de equipo
  defp parsear_comando("/chat " <> equipo) when equipo != "" do
    {:ver_chat, String.trim(equipo)}
  end

  # /send <participante_id> | <mensaje> - Enviar mensaje
  defp parsear_comando("/send " <> args) do
    case String.split(args, "|", parts: 2) do
      [id, mensaje] -> {:enviar_mensaje, String.trim(id), String.trim(mensaje)}
      _ -> {:error, "Uso: /send <participante_id> | <mensaje>"}
    end
  end

  # /announce <participante_id> | <anuncio> - Enviar anuncio
  defp parsear_comando("/announce " <> args) do
    case String.split(args, "|", parts: 2) do
      [id, anuncio] -> {:enviar_anuncio, String.trim(id), String.trim(anuncio)}
      _ -> {:error, "Uso: /announce <organizador_id> | <anuncio>"}
    end
  end

  # /announcements - Ver anuncios
  defp parsear_comando("/announcements"), do: {:ver_anuncios}

  # ========== MENTORÍA ==========

  # /mentors - Listar mentores
  defp parsear_comando("/mentors"), do: {:listar_mentores}

  # /register-mentor <nombre> <especialidad> - Registrar mentor
  defp parsear_comando("/register-mentor " <> args) do
    case String.split(args, " ", parts: 2) do
      [nombre, especialidad] ->
        {:registrar_mentor, String.trim(nombre), String.trim(especialidad)}

      _ ->
        {:error, "Uso: /register-mentor <nombre> <especialidad>"}
    end
  end

  # /assign-mentor <mentor_id> | <equipo> - Asignar mentor
  defp parsear_comando("/assign-mentor " <> args) do
    case String.split(args, "|", parts: 2) do
      [mentor_id, equipo] -> {:asignar_mentor, String.trim(mentor_id), String.trim(equipo)}
      _ -> {:error, "Uso: /assign-mentor <mentor_id> | <equipo>"}
    end
  end

  # /feedback <mentor_id> | <equipo> | <comentario> - Dar feedback
  defp parsear_comando("/feedback " <> args) do
    case String.split(args, "|", parts: 3) do
      [mentor_id, equipo, comentario] ->
        {:dar_feedback, String.trim(mentor_id), String.trim(equipo), String.trim(comentario)}

      _ ->
        {:error, "Uso: /feedback <mentor_id> | <equipo> | <comentario>"}
    end
  end

  # ========== ESTADÍSTICAS ==========

  # /stats - Estadísticas generales
  defp parsear_comando("/stats"), do: {:estadisticas_generales}

  # /stats <equipo> - Estadísticas de equipo
  defp parsear_comando("/stats " <> equipo) when equipo != "" do
    {:estadisticas_equipo, String.trim(equipo)}
  end

  # ========== COMANDO DESCONOCIDO ==========

  defp parsear_comando(""), do: {:vacio}

  defp parsear_comando(comando) do
    {:desconocido, comando}
  end
end
