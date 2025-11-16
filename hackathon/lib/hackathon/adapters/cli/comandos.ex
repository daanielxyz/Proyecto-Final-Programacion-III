defmodule Hackathon.Adapters.CLI.Comandos do
  @moduledoc """
  Ejecuta los comandos parseados conectándolos con los Services.
  """

  alias Hackathon.Services.{GestionEquipos, GestionParticipantes, GestionProyectos, ChatService, MentoriaService}
  alias Hackathon.Adapters.CLI.UI
  alias Hackathon.Utils.Colores

  @doc """
  Ejecuta un comando parseado.
  """
  def ejecutar({:ayuda}) do
    UI.mostrar_ayuda()
    :continuar
  end

  def ejecutar({:salir}) do
    UI.info("¡Hasta pronto! 👋")
    :salir
  end

  def ejecutar({:limpiar}) do
    UI.limpiar_pantalla()
    :continuar
  end

  def ejecutar({:vacio}), do: :continuar

  # ========== EQUIPOS ==========

  def ejecutar({:listar_equipos}) do
    {:ok, equipos} = GestionEquipos.listar_equipos()
    UI.mostrar_equipos(equipos)
    :continuar
  end

  def ejecutar({:crear_equipo, nombre}) do
    case GestionEquipos.crear_equipo(nombre) do
      {:ok, equipo} -> UI.exito("Equipo '#{equipo.nombre}' creado con ID: #{equipo.id}")
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:ver_equipo, nombre}) do
    case GestionEquipos.ver_equipo(nombre) do
      {:ok, detalle} -> UI.mostrar_detalle_equipo(detalle)
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:unirse_equipo, equipo}) do
    UI.info("Para unirte necesitas tu ID de participante.")
    IO.write("Ingresa tu ID: ")
    participante_id = IO.gets("") |> String.trim()

    case GestionEquipos.unir_participante_a_equipo(participante_id, equipo) do
      {:ok, msg} -> UI.exito(msg)
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  # ========== PARTICIPANTES ==========

  def ejecutar({:registrar_participante, nombre, correo}) do
    case GestionParticipantes.registrar(nombre, correo) do
      {:ok, participante} ->
        UI.exito("Participante registrado con ID: #{participante.id}")
        UI.info("Guarda tu ID para usar el sistema")
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:listar_participantes}) do
    {:ok, participantes} = GestionParticipantes.listar_participantes()
    IO.puts("\n📋 PARTICIPANTES REGISTRADOS (#{length(participantes)})\n")
    Enum.each(participantes, fn p ->
      equipo = if p.nombre_equipo, do: "→ #{p.nombre_equipo}", else: "(sin equipo)"
      IO.puts("• #{p.nombre} - #{p.correo} #{equipo}")
      IO.puts("  ID: #{p.id}")
    end)
    :continuar
  end

  def ejecutar({:ver_participante, correo}) do
    case GestionParticipantes.ver_participante(correo) do
      {:ok, detalle} ->
        IO.puts("\n👤 #{detalle.nombre}")
        IO.puts("ID: #{detalle.id}")
        IO.puts("Correo: #{detalle.correo}")
        IO.puts("Rol: #{detalle.rol}")
        if detalle.tiene_equipo do
          IO.puts("Equipo: #{detalle.nombre_equipo}")
        else
          IO.puts("Sin equipo asignado")
        end
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  # ========== PROYECTOS ==========

  def ejecutar({:listar_proyectos}) do
    {:ok, proyectos} = GestionProyectos.listar_proyectos()
    UI.mostrar_proyectos(proyectos)
    :continuar
  end

  def ejecutar({:ver_proyecto, equipo}) do
    case GestionProyectos.ver_proyecto(equipo) do
      {:ok, proyecto} -> UI.mostrar_detalle_proyecto(proyecto)
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:registrar_proyecto, equipo, titulo, descripcion, categoria}) do
    # Primero obtener el ID del equipo
    case GestionEquipos.ver_equipo(equipo) do
      {:ok, detalle_equipo} ->
        case GestionProyectos.registrar_proyecto(detalle_equipo.id, titulo, descripcion, categoria) do
          {:ok, _proyecto} -> UI.exito("Proyecto registrado correctamente")
          {:error, msg} -> UI.error(msg)
        end
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:actualizar_avance, equipo, texto}) do
    case GestionEquipos.ver_equipo(equipo) do
      {:ok, detalle_equipo} ->
        case GestionProyectos.actualizar_avance(detalle_equipo.id, texto) do
          {:ok, msg} -> UI.exito(msg)
          {:error, msg} -> UI.error(msg)
        end
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  # ========== CHAT ==========

  def ejecutar({:ver_chat, equipo}) do
    case ChatService.ver_chat(equipo) do
      {:ok, mensajes} -> UI.mostrar_chat(equipo, mensajes)
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:enviar_mensaje, participante_id, contenido}) do
    case ChatService.enviar_mensaje(participante_id, contenido) do
      {:ok, msg} -> UI.exito(msg)
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:enviar_anuncio, participante_id, contenido}) do
    case ChatService.enviar_anuncio(participante_id, contenido) do
      {:ok, msg} -> UI.exito(msg)
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:ver_anuncios}) do
    {:ok, anuncios} = ChatService.ver_anuncios()
    IO.puts("\n" <> Colores.destacado("ANUNCIOS") <> "\n")
    if Enum.empty?(anuncios) do
      IO.puts(Colores.advertencia("No hay anuncios"))
    else
      Enum.each(anuncios, fn a ->
        IO.puts("#{a.fecha}")
        IO.puts("#{a.emisor}: #{a.contenido}\n")
      end)
    end
    :continuar
  end

  # ========== MENTORÍA ==========

  def ejecutar({:listar_mentores}) do
    {:ok, mentores} = MentoriaService.listar_mentores()
    IO.puts("\n🎓 MENTORES REGISTRADOS (#{length(mentores)})\n")
    Enum.each(mentores, fn m ->
      disponible = if m.disponible, do: "✓ Disponible", else: "✗ No disponible"
      IO.puts("• #{m.nombre} - #{m.especialidad}")
      IO.puts("  ID: #{m.id}")
      IO.puts("  Equipos: #{m.cantidad_equipos} #{disponible}")
    end)
    :continuar
  end

  def ejecutar({:registrar_mentor, nombre, especialidad}) do
    case MentoriaService.registrar_mentor(nombre, especialidad) do
      {:ok, mentor} ->
        UI.exito("Mentor registrado con ID: #{mentor.id}")
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:asignar_mentor, mentor_id, equipo}) do
    case MentoriaService.asignar_mentor_a_equipo(mentor_id, equipo) do
      {:ok, msg} -> UI.exito(msg)
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  def ejecutar({:dar_feedback, mentor_id, equipo, comentario}) do
    case MentoriaService.dar_feedback(mentor_id, equipo, comentario) do
      {:ok, msg} -> UI.exito(msg)
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  # ========== ESTADÍSTICAS ==========

  def ejecutar({:estadisticas_generales}) do
    stats = %{
      equipos: GestionEquipos.contar_equipos(),
      participantes: GestionParticipantes.contar_participantes(),
      proyectos: GestionProyectos.contar_proyectos(),
      mentores: MentoriaService.contar_mentores()
    }
    UI.mostrar_estadisticas_generales(stats)
    :continuar
  end

  def ejecutar({:estadisticas_equipo, equipo}) do
    case ChatService.estadisticas_equipo(equipo) do
      {:ok, stats} ->
        IO.puts("\n📊 ESTADÍSTICAS: #{stats.equipo}")
        IO.puts("Mensajes totales: #{stats.total_mensajes}\n")
        IO.puts("Mensajes por participante:")
        Enum.each(stats.mensajes_por_participante, fn p ->
          IO.puts("  • #{p.nombre}: #{p.cantidad} mensajes")
        end)
      {:error, msg} -> UI.error(msg)
    end
    :continuar
  end

  # ========== ERROR ==========

  def ejecutar({:error, mensaje}) do
    UI.error(mensaje)
    :continuar
  end

  def ejecutar({:desconocido, comando}) do
    UI.error("Comando desconocido: #{comando}")
    UI.info("Escribe /help para ver los comandos disponibles")
    :continuar
  end
end
