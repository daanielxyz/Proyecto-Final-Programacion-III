# Manual de Usuario - Sistema Hackathon Code4Future

---

## Índice
1. [Introducción](#1-introducción)
2. [Inicio Rápido](#2-inicio-rápido)
3. [Registro en el Sistema](#3-registro-en-el-sistema)
4. [Gestión de Equipos](#4-gestión-de-equipos)
5. [Trabajo con Proyectos](#5-trabajo-con-proyectos)
6. [Sistema de Chat](#6-sistema-de-chat)
7. [Mentoría](#7-mentoría)
8. [Estadísticas](#8-estadísticas)
9. [Preguntas Frecuentes](#9-preguntas-frecuentes)
10. [Solución de Problemas](#10-solución-de-problemas)

---

## 1. Introducción

### ¿Qué es el Sistema Hackathon Code4Future?

Es una plataforma de gestión que facilita la organización de hackathons, permitiendo:
-  Formar y gestionar equipos
-  Registrar y dar seguimiento a proyectos
-  Comunicarse en tiempo real
-  Recibir mentoría especializada
-  Visualizar estadísticas y avances

### Roles en el Sistema

**Participante**
- Puede unirse a un equipo
- Registra proyectos
- Envía mensajes al chat de su equipo
- Actualiza avances

**Mentor**
- Se asigna a equipos (máximo 3)
- Da retroalimentación sobre proyectos
- Apoya a los equipos con su experiencia

**Organizador**
- Supervisa el evento
- Envía anuncios generales
- Accede a estadísticas globales

---

## 2. Inicio Rápido

### Paso 1: Ejecutar el Sistema

**En Windows:**
```bash
escript hackathon
```

**En Linux/Mac:**
```bash
./hackathon
```

### Paso 2: Pantalla de Bienvenida

Verás algo como esto:

```
╔═════════════════════════╗
║  HACKATHON CODE4FUTURE  ║
╚═════════════════════════╝
ℹ Sistema de Gestión Colaborativa
──────────────────────────────────────────────────

Escribe /help para ver los comandos disponibles
Escribe /exit para salir

hackathon>
```

### Paso 3: Ver Comandos Disponibles

Escribe:
```bash
/help
```

---

## 3. Registro en el Sistema

### 3.1 Registrarse como Participante

**Comando:**
```bash
/register [Tu Nombre] [tu@email.com]
```

**Ejemplo:**
```bash
hackathon> /register Juan Pérez juan@email.com

✓ Participante registrado con ID: a1b2c3d4
ℹ Guarda tu ID para usar el sistema
```

**IMPORTANTE:** Guarda tu ID, lo necesitarás para:
- Unirte a equipos
- Enviar mensajes
- Actualizar avances

### 3.2 Registrarse como Organizador

**Comando:**
```bash
/register-organizer [Nombre] [email@hackathon.com]
```

**Ejemplo:**
```bash
hackathon> /register-organizer Admin admin@hackathon.com

✓ Organizador registrado con ID: x9y8z7w6
```

### 3.3 Ver Tu Información

**Comando:**
```bash
/me [tu@email.com]
```

**Ejemplo:**
```bash
hackathon> /me juan@email.com

👤 Juan Pérez
ID: a1b2c3d4
Correo: juan@email.com
Rol: participante
Sin equipo asignado
```

---

## 4. Gestión de Equipos

### 4.1 Crear un Equipo

**Comando:**
```bash
/teams create [Nombre del Equipo]
```

**Ejemplo:**
```bash
hackathon> /teams create Los Innovadores

✓ Equipo 'Los Innovadores' creado con ID: m5n6o7p8
```

### 4.2 Ver Todos los Equipos

**Comando:**
```bash
/teams
```

**Salida:**
```
╔═══════════════════════════╗
║  EQUIPOS REGISTRADOS (3)  ║
╚═══════════════════════════╝

Los Innovadores ✓
  ID: m5n6o7p8
  Integrantes: 2
  Proyecto: [PROYECTO] Registrado

Tech Warriors ✓
  ID: q1r2s3t4
  Integrantes: 1
  Proyecto: [PENDIENTE] Pendiente
```

### 4.3 Ver Detalles de un Equipo

**Comando:**
```bash
/team [Nombre del Equipo]
```

**Ejemplo:**
```bash
hackathon> /team Los Innovadores

╔═════════════════════════════════╗
║  EQUIPO: Los Innovadores  ║
╚═════════════════════════════════╝
ID: m5n6o7p8
Estado: activo

Integrantes (2):
  • Juan Pérez (juan@email.com)
  • María García (maria@email.com)

✓ Proyecto registrado
```

### 4.4 Unirse a un Equipo

**Comando:**
```bash
/join [Nombre del Equipo]
```

**Ejemplo:**
```bash
hackathon> /join Los Innovadores
ℹ Para unirte necesitas tu ID de participante.
Ingresa tu ID: a1b2c3d4

✓ Juan Pérez se ha unido al equipo Los Innovadores
```

**Validaciones:**
-  No puedes estar en dos equipos a la vez
-  No puedes unirte dos veces al mismo equipo

### 4.5 Listar Participantes

**Comando:**
```bash
/participants
```

**Salida:**
```
PARTICIPANTES REGISTRADOS (5)

• Juan Pérez - juan@email.com → Los Innovadores
  ID: a1b2c3d4
• Carlos Ruiz - carlos@email.com (sin equipo)
  ID: e5f6g7h8
```

---

## 5. Trabajo con Proyectos

### 5.1 Registrar un Proyecto

**Comando:**
```bash
/register-project [Equipo] | [Título] | [Descripción] | [Categoría]
```

**Categorías válidas:**
- `social` - Impacto social
- `ambiental` - Sostenibilidad y medio ambiente
- `educativo` - Educación y aprendizaje

**Ejemplo:**
```bash
hackathon> /register-project Los Innovadores | EcoApp | Aplicación para reciclaje inteligente con IA | ambiental

✓ Proyecto registrado correctamente
```

### 5.2 Ver Proyecto de un Equipo

**Comando:**
```bash
/project [Nombre del Equipo]
```

**Ejemplo:**
```bash
hackathon> /project Los Innovadores

╔══════════════════════════╗
║  PROYECTO: EcoApp  ║
╚══════════════════════════╝
Equipo: Los Innovadores
Categoría: ambiental
Estado: idea

Descripción:
  Aplicación para reciclaje inteligente con IA

Avances (2):
  • Completado diseño de interfaz
  • Implementado reconocimiento de materiales

Retroalimentación (1):
  💬 Excelente idea, enfóquense en la UX
```

### 5.3 Actualizar Avances del Proyecto

**Comando:**
```bash
/progress [Equipo] | [Texto del Avance]
```

**Ejemplo:**
```bash
hackathon> /progress Los Innovadores | Completado el módulo de escaneo con cámara

✓ Avance registrado correctamente
```

**Tip:** Actualiza avances regularmente para que mentores y organizadores sigan tu progreso.

### 5.4 Listar Todos los Proyectos

**Comando:**
```bash
/projects
```

**Salida:**
```
╔═══════════════════════════════╗
║  PROYECTOS REGISTRADOS (2)  ║
╚═══════════════════════════════╝

EcoApp - Los Innovadores
  Categoría: ambiental
  Estado: desarrollo
  Avances: 3 | Feedback: 2

EduTech - Tech Warriors
  Categoría: educativo
  Estado: idea
  Avances: 1 | Feedback: 0
```

---

## 6. Sistema de Chat

### 6.1 Enviar un Mensaje

**Comando:**
```bash
/send [Tu ID] | [Mensaje]
```

**Ejemplo:**
```bash
hackathon> /send a1b2c3d4 | Hola equipo! ¿Listos para empezar?

✓ Mensaje enviado
```

**Nota:** Solo puedes enviar mensajes si estás en un equipo.

### 6.2 Ver Chat del Equipo

**Comando:**
```bash
/chat [Nombre del Equipo]
```

**Ejemplo:**
```bash
hackathon> /chat Los Innovadores

╔═══════════════════════════════╗
║  CHAT: Los Innovadores  ║
╚═══════════════════════════════╝

[14:30] Juan Pérez: Hola equipo! ¿Listos para empezar?
[14:32] María García: ¡Sí! Vamos con todo 🚀
[14:35] Juan Pérez: Perfecto, yo me encargo del backend
```

### 6.3 Anuncios Generales (Solo Organizadores)

**Comando:**
```bash
/announce [ID de Organizador] | [Anuncio]
```

**Ejemplo:**
```bash
hackathon> /announce x9y8z7w6 | ¡La hackathon ha comenzado oficialmente!

✓ Anuncio publicado
```

### 6.4 Ver Anuncios

**Comando:**
```bash
/announcements
```

**Salida:**
```
ANUNCIOS

2024-11-06 10:00:00
Admin: ¡La hackathon ha comenzado oficialmente!

2024-11-06 15:00:00
Admin: Recuerden que tienen hasta las 18:00 para registrar avances
```

---

## 7. Mentoría

### 7.1 Registrar un Mentor

**Comando:**
```bash
/register-mentor [Nombre] [Especialidad]
```

**Ejemplo:**
```bash
hackathon> /register-mentor Dr.García Inteligencia_Artificial

✓ Mentor registrado con ID: q9r8s7t6
```

### 7.2 Ver Mentores Disponibles

**Comando:**
```bash
/mentors
```

**Salida:**
```
MENTORES REGISTRADOS (3)

• Dr. García - Inteligencia Artificial
  ID: q9r8s7t6
  Equipos: 1 ✓ Disponible

• Dra. Martínez - Desarrollo Web
  ID: u5v4w3x2
  Equipos: 3 ✗ No disponible
```

### 7.3 Asignar Mentor a Equipo

**Comando:**
```bash
/assign-mentor [ID del Mentor] | [Nombre del Equipo]
```

**Ejemplo:**
```bash
hackathon> /assign-mentor q9r8s7t6 | Los Innovadores

✓ Mentor Dr. García asignado al equipo Los Innovadores
```

### 7.4 Dar Retroalimentación (Solo Mentores)

**Comando:**
```bash
/feedback [ID del Mentor] | [Nombre del Equipo] | [Comentario]
```

**Ejemplo:**
```bash
hackathon> /feedback q9r8s7t6 | Los Innovadores | Excelente progreso en el reconocimiento de imágenes. Consideren usar transfer learning para mejorar precisión.

✓ Retroalimentación registrada
```

---

## 8. Estadísticas

### 8.1 Estadísticas Generales

**Comando:**
```bash
/stats
```

**Salida:**
```
╔═══════════════════════════════╗
║  ESTADÍSTICAS GENERALES  ║
╚═══════════════════════════════╝
Equipos: 5
Participantes: 12
Proyectos: 4
Mentores: 3
```

### 8.2 Estadísticas de Equipo

**Comando:**
```bash
/stats [Nombre del Equipo]
```

**Ejemplo:**
```bash
hackathon> /stats Los Innovadores

ESTADÍSTICAS: Los Innovadores
Mensajes totales: 24

Mensajes por participante:
  • Juan Pérez: 15 mensajes
  • María García: 9 mensajes
```

---

## 9. Preguntas Frecuentes

### ¿Cómo recupero mi ID si lo perdí?

Usa el comando:
```bash
/me [tu@email.com]
```

### ¿Puedo cambiarme de equipo?

No, por el momento solo puedes estar en un equipo. Si necesitas cambiarte, contacta a un organizador.

### ¿Cuántos mentores puede tener un equipo?

Un equipo puede tener múltiples mentores. Cada mentor puede atender hasta 3 equipos.

### ¿Puedo ver el chat de otro equipo?

No, solo puedes ver el chat de tu propio equipo. Los organizadores pueden ver todos.

### ¿Cómo salgo del sistema?

Usa el comando:
```bash
/exit
```

### ¿Se guardan mis datos?

Sí, todos los datos se guardan automáticamente en archivos JSON en la carpeta `data/`.

---

## 10. Solución de Problemas

### Problema: "Participante no encontrado"

**Causa:** El correo no está registrado o tiene un error tipográfico.

**Solución:**
1. Verifica que escribiste bien el correo
2. Usa `/participants` para ver todos los registrados
3. Si no estás registrado, usa `/register`

### Problema: "El equipo ya tiene un proyecto registrado"

**Causa:** Solo se permite un proyecto por equipo.

**Solución:** Usa `/progress` para actualizar avances en lugar de crear un nuevo proyecto.

### Problema: "No puedes enviar mensajes sin equipo"

**Causa:** No estás asignado a ningún equipo.

**Solución:** Únete a un equipo con `/join [Equipo]`

### Problema: "El mentor no está disponible"

**Causa:** El mentor ya tiene 3 equipos asignados.

**Solución:** 
1. Usa `/mentors` para ver mentores disponibles
2. Elige uno con estado "✓ Disponible"

### Problema: Caracteres raros en la terminal (Windows)

**Causa:** Codificación de caracteres incorrecta.

**Solución:**
```bash
chcp 65001
escript hackathon
```

---

## 11. Comandos Rápidos

### Referencia Rápida

| Acción | Comando |
|--------|---------|
| Ver ayuda | `/help` |
| Registrarse | `/register Nombre correo@email.com` |
| Crear equipo | `/teams create NombreEquipo` |
| Ver equipos | `/teams` |
| Unirse a equipo | `/join NombreEquipo` |
| Registrar proyecto | `/register-project Equipo \| Título \| Desc \| Categoría` |
| Ver proyecto | `/project NombreEquipo` |
| Actualizar avance | `/progress Equipo \| Texto` |
| Enviar mensaje | `/send ID \| Mensaje` |
| Ver chat | `/chat NombreEquipo` |
| Ver estadísticas | `/stats` |
| Salir | `/exit` |

---

## 12. Consejos y Mejores Prácticas

### Para Participantes

**Registra avances frecuentemente** - Mantén actualizado tu progreso

**Comunícate con tu equipo** - Usa el chat para coordinarte

**Guarda tu ID** - Lo necesitarás constantemente

**Lee la retroalimentación** - Los mentores tienen experiencia valiosa

### Para Mentores

**Da feedback constructivo** - Sé específico y útil

**Revisa proyectos regularmente** - Mantente al tanto del progreso

**No te sobrecargues** - Máximo 3 equipos para dar atención de calidad

### Para Organizadores

**Envía anuncios importantes** - Mantén informados a todos

**Monitorea estadísticas** - Identifica equipos que necesitan apoyo

**Responde preguntas** - Sé accesible para los participantes

---