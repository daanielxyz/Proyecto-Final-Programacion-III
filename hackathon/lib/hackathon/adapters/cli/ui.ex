defmodule Hackathon.Adapters.CLI.UI do
  @moduledoc """
  Módulo para formatear y mostrar información en la CLI.
  Usa colores y formato para una mejor experiencia de usuario.
  """

  alias Hackathon.Utils.Colores

  @doc """
  Muestra el banner de bienvenida.
  """
  def mostrar_banner do
    IO.puts("\n")
    IO.puts(Colores.titulo("HACKATHON CODE4FUTURE"))
    IO.puts(Colores.info("Sistema de Gestión Colaborativa"))
    IO.puts(Colores.separador())
    IO.puts("\nEscribe #{Colores.comando("/help")} para ver los comandos disponibles")
    IO.puts("Escribe #{Colores.comando("/exit")} para salir\n")
  end

  @doc """
  Muestra el prompt para entrada del usuario.
  """
  def prompt do
    IO.write(Colores.destacado("\nhackathon> "))
  end

  @doc """
  Muestra el menú de ayuda con todos los comandos.
  """
  def mostrar_ayuda do
    IO.puts("\n" <> Colores.titulo("COMANDOS DISPONIBLES"))

    IO.puts(Colores.destacado("\n[EQUIPOS]:"))
    IO.puts("  #{Colores.comando("/teams")}                    - Listar todos los equipos")
    IO.puts("  #{Colores.comando("/teams create <nombre>")}    - Crear un nuevo equipo")
    IO.puts("  #{Colores.comando("/team <nombre>")}            - Ver detalles de un equipo")
    IO.puts("  #{Colores.comando("/join <equipo>")}            - Unirse a un equipo")

    IO.puts(Colores.destacado("\n[PARTICIPANTES]:"))
    IO.puts("  #{Colores.comando("/register <nombre> <correo>")} - Registrarse como participante")
    IO.puts("  #{Colores.comando("/participants")}                - Listar participantes")
    IO.puts("  #{Colores.comando("/me <correo>")}                 - Ver mi información")
    IO.puts("  #{Colores.comando("/register-organizer <Nombre> <Correo>")} - Registrar como organizador")


    IO.puts(Colores.destacado("\n[PROYECTOS]:"))
    IO.puts("  #{Colores.comando("/projects")}                              - Listar todos los proyectos")
    IO.puts("  #{Colores.comando("/project <equipo>")}                      - Ver proyecto de un equipo")
    IO.puts("  #{Colores.comando("/register-project <equipo> | <titulo> | <desc> | <categoria>")}")
    IO.puts("  #{Colores.comando("/progress <equipo> | <avance>")}         - Actualizar avance")

    IO.puts(Colores.destacado("\n[CHAT]:"))
    IO.puts("  #{Colores.comando("/chat <equipo>")}                    - Ver chat de equipo")
    IO.puts("  #{Colores.comando("/send <id> | <mensaje>")}           - Enviar mensaje")
    IO.puts("  #{Colores.comando("/announce <id> | <anuncio>")}       - Enviar anuncio (organizadores)")
    IO.puts("  #{Colores.comando("/announcements")}                   - Ver anuncios")

    IO.puts(Colores.destacado("\n[MENTORIA]:"))
    IO.puts("  #{Colores.comando("/mentors")}                                - Listar mentores")
    IO.puts("  #{Colores.comando("/register-mentor <nombre> <especialidad>")} - Registrar mentor")
    IO.puts("  #{Colores.comando("/assign-mentor <id> | <equipo>")}          - Asignar mentor")
    IO.puts("  #{Colores.comando("/feedback <id> | <equipo> | <comentario>")} - Dar feedback")

    IO.puts(Colores.destacado("\n[ESTADISTICAS]:"))
    IO.puts("  #{Colores.comando("/stats")}          - Estadísticas generales")
    IO.puts("  #{Colores.comando("/stats <equipo>")} - Estadísticas de equipo")

    IO.puts(Colores.destacado("\n[OTROS]:"))
    IO.puts("  #{Colores.comando("/help")}   - Mostrar esta ayuda")
    IO.puts("  #{Colores.comando("/clear")}  - Limpiar pantalla")
    IO.puts("  #{Colores.comando("/exit")}   - Salir del sistema")

    IO.puts("\n" <> Colores.separador() <> "\n")
  end

  @doc """
  Muestra una lista de equipos.
  """
  def mostrar_equipos(equipos) when is_list(equipos) do
    if Enum.empty?(equipos) do
      IO.puts(Colores.advertencia("No hay equipos registrados"))
    else
      IO.puts("\n" <> Colores.titulo("EQUIPOS REGISTRADOS (#{length(equipos)})"))

      Enum.each(equipos, fn equipo ->
        estado_icono = if equipo.estado == :activo, do: "[OK]", else: "[X]"
        proyecto_icono = if equipo.tiene_proyecto, do: "[PROYECTO]", else: "[PENDIENTE]"

        IO.puts("\n#{Colores.destacado(equipo.nombre)} #{estado_icono}")
        IO.puts("  ID: #{equipo.id}")
        IO.puts("  Integrantes: #{equipo.cantidad_integrantes}")
        IO.puts("  Proyecto: #{proyecto_icono} #{if equipo.tiene_proyecto, do: "Registrado", else: "Pendiente"}")
      end)

      IO.puts("\n" <> Colores.separador())
    end
  end

  @doc """
  Muestra detalles de un equipo.
  """
  def mostrar_detalle_equipo(detalle) do
    IO.puts("\n" <> Colores.titulo("EQUIPO: #{detalle.nombre}"))
    IO.puts("ID: #{detalle.id}")
    IO.puts("Estado: #{detalle.estado}")

    IO.puts(Colores.destacado("\nIntegrantes (#{length(detalle.integrantes)}):"))
    if Enum.empty?(detalle.integrantes) do
      IO.puts("  " <> Colores.advertencia("Sin integrantes aún"))
    else
      Enum.each(detalle.integrantes, fn integrante ->
        IO.puts("  • #{integrante.nombre} (#{integrante.correo})")
      end)
    end

    if detalle.tiene_proyecto do
      IO.puts(Colores.exito("\n✓ Proyecto registrado"))
    else
      IO.puts(Colores.advertencia("\n⚠ Sin proyecto registrado"))
    end

    IO.puts("\n" <> Colores.separador())
  end

  @doc """
  Muestra lista de proyectos.
  """
  def mostrar_proyectos(proyectos) when is_list(proyectos) do
    if Enum.empty?(proyectos) do
      IO.puts(Colores.advertencia("No hay proyectos registrados"))
    else
      IO.puts("\n" <> Colores.titulo("PROYECTOS REGISTRADOS (#{length(proyectos)})"))

      Enum.each(proyectos, fn p ->
        IO.puts("\n#{Colores.destacado(p.titulo)} - #{p.equipo}")
        IO.puts("  Categoría: #{p.categoria}")
        IO.puts("  Estado: #{p.estado}")
        IO.puts("  Avances: #{p.avances} | Feedback: #{p.feedback}")
      end)

      IO.puts("\n" <> Colores.separador())
    end
  end

  @doc """
  Muestra detalles de un proyecto.
  """
  def mostrar_detalle_proyecto(proyecto) do
    IO.puts("\n" <> Colores.titulo("PROYECTO: #{proyecto.titulo}"))
    IO.puts("Equipo: #{proyecto.equipo}")
    IO.puts("Categoría: #{proyecto.categoria}")
    IO.puts("Estado: #{proyecto.estado}")
    IO.puts("\nDescripción:")
    IO.puts("  #{proyecto.descripcion}")

    IO.puts(Colores.destacado("\nAvances (#{proyecto.cantidad_avances}):"))
    if Enum.empty?(proyecto.avances) do
      IO.puts("  " <> Colores.advertencia("Sin avances registrados"))
    else
      proyecto.avances
      |> Enum.reverse()
      |> Enum.each(fn avance ->
        IO.puts("  • #{avance.texto}")
      end)
    end

    IO.puts(Colores.destacado("\nRetroalimentación (#{proyecto.cantidad_feedback}):"))
    if Enum.empty?(proyecto.retroalimentacion) do
      IO.puts("  " <> Colores.advertencia("Sin feedback de mentores"))
    else
      proyecto.retroalimentacion
      |> Enum.reverse()
      |> Enum.each(fn feedback ->
        IO.puts("  💬 #{feedback.comentario}")
      end)
    end

    IO.puts("\n" <> Colores.separador())
  end

  @doc """
  Muestra mensajes de chat.
  """
  def mostrar_chat(equipo, mensajes) when is_list(mensajes) do
    IO.puts("\n" <> Colores.titulo("CHAT: #{equipo}"))

    if Enum.empty?(mensajes) do
      IO.puts(Colores.advertencia("No hay mensajes aún"))
    else
      mensajes
      |> Enum.reverse()
      |> Enum.each(fn msg ->
        IO.puts("[#{msg.hora}] #{Colores.destacado(msg.emisor)}: #{msg.contenido}")
      end)
    end

    IO.puts("\n" <> Colores.separador())
  end

  @doc """
  Muestra mensaje de éxito.
  """
  def exito(mensaje), do: IO.puts("\n" <> Colores.exito(mensaje))

  @doc """
  Muestra mensaje de error.
  """
  def error(mensaje), do: IO.puts("\n" <> Colores.error(mensaje))

  @doc """
  Muestra mensaje informativo.
  """
  def info(mensaje), do: IO.puts("\n" <> Colores.info(mensaje))

  @doc """
  Muestra advertencia.
  """
  def advertencia(mensaje), do: IO.puts("\n" <> Colores.advertencia(mensaje))

  @doc """
  Limpia la pantalla.
  """
  def limpiar_pantalla do
    IO.write("\e[H\e[2J")
  end

  @doc """
  Muestra estadísticas generales.
  """
  def mostrar_estadisticas_generales(stats) do
    IO.puts("\n" <> Colores.titulo("ESTADÍSTICAS GENERALES"))
    IO.puts("Equipos: #{stats.equipos}")
    IO.puts("Participantes: #{stats.participantes}")
    IO.puts("Proyectos: #{stats.proyectos}")
    IO.puts("Mentores: #{stats.mentores}")
    IO.puts("\n" <> Colores.separador())
  end
end
