# Documentación Técnica - Sistema de Gestión Hackathon Code4Future

**Lenguaje:** Elixir 
**Autores:** José Daniel Valencia Herrera, Santiago Arias Rodriguez

---

## 1. Introducción

### 1.1 Propósito del Sistema
Sistema de gestión colaborativa para organizar y administrar hackathons, permitiendo:
- Registro de participantes y equipos
- Gestión de proyectos y avances
- Comunicación en tiempo real
- Sistema de mentoría
- Estadísticas y seguimiento

### 1.2 Alcance
El sistema cubre todas las necesidades operativas de una hackathon de 48 horas, desde el registro inicial hasta el seguimiento de proyectos finales.

### 1.3 Tecnologías Utilizadas
- **Lenguaje:** Elixir 1.18.4
- **Runtime:** Erlang/OTP 27
- **Persistencia:** Archivos JSON
- **Dependencias:**
  - `jason ~> 1.4` - Manejo de JSON
  - `uuid ~> 1.1` - Generación de identificadores únicos

---

## 2. Arquitectura del Sistema

### 2.1 Patrón Arquitectónico
El sistema implementa una **arquitectura hexagonal (Ports & Adapters)** adaptada para aplicaciones de consola, dividida en tres capas principales:

```
┌─────────────────────────────────────────┐
│          ADAPTERS (CLI/Persistencia)    │
│  - CLI (Comandos, Parser, UI)           │
│  - RepositoriosJSON (Equipos, etc.)     │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│           SERVICES (Lógica Negocio)     │
│  - GestionEquipos                       │
│  - GestionParticipantes                 │
│  - GestionProyectos                     │
│  - ChatService                          │
│  - MentoriaService                      │
└─────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────┐
│          DOMAIN (Entidades Puras)       │
│  - Equipo, Participante, Proyecto       │
│  - Mensaje, Mentor                      │
└─────────────────────────────────────────┘
```

### 2.2 Estructura de Directorios

```
hackathon/
├── lib/
│   └── hackathon/
│       ├── domain/              # Entidades del negocio
│       │   ├── equipo.ex
│       │   ├── participante.ex
│       │   ├── proyecto.ex
│       │   ├── mensaje.ex
│       │   └── mentor.ex
│       │
│       ├── services/            # Casos de uso
│       │   ├── gestion_equipos.ex
│       │   ├── gestion_participantes.ex
│       │   ├── gestion_proyectos.ex
│       │   ├── chat_service.ex
│       │   └── mentoria_service.ex
│       │
│       ├── adapters/            # Adaptadores externos
│       │   ├── cli/
│       │   │   ├── comandos.ex
│       │   │   ├── parser.ex
│       │   │   └── ui.ex
│       │   └── persistencia/
│       │       ├── repositorio_equipos.ex
│       │       ├── repositorio_participantes.ex
│       │       ├── repositorio_proyectos.ex
│       │       ├── repositorio_mensajes.ex
│       │       └── repositorio_mentores.ex
│       │
│       ├── core/                # Funcionalidades centrales
│       │   └── validaciones.ex
│       │
│       └── utils/               # Utilidades
│           ├── colores.ex
│           ├── uuid_helper.ex
│           └── fecha_helper.ex
│
├── data/                        # Persistencia JSON
│   ├── equipos.json
│   ├── participantes.json
│   ├── proyectos.json
│   ├── mensajes.json
│   └── mentores.json
│
├── test/                        # Pruebas unitarias
├── mix.exs                      # Configuración del proyecto
└── README.md
```

---

## 3. Capa de Dominio

### 3.1 Entidades Principales

#### Equipo
```elixir
%Equipo{
  id: String.t(),              # ID único (8 caracteres)
  nombre: String.t(),          # Nombre del equipo
  integrantes: [String.t()],   # IDs de participantes
  proyecto_id: String.t() | nil,
  mentores_ids: [String.t()],  # IDs de mentores asignados
  fecha_creacion: DateTime.t(),
  estado: :activo | :inactivo
}
```

#### Participante
```elixir
%Participante{
  id: String.t(),
  nombre: String.t(),
  correo: String.t(),
  rol: :participante | :mentor | :organizador,
  equipo_id: String.t() | nil,
  fecha_registro: DateTime.t()
}
```

#### Proyecto
```elixir
%Proyecto{
  id: String.t(),
  equipo_id: String.t(),
  titulo: String.t(),
  descripcion: String.t(),
  categoria: "social" | "ambiental" | "educativo",
  estado: "idea" | "desarrollo" | "finalizado",
  avances: [%{texto: String.t(), fecha: DateTime.t()}],
  retroalimentacion: [%{mentor_id: String.t(), comentario: String.t(), fecha: DateTime.t()}],
  fecha_creacion: DateTime.t()
}
```

#### Mensaje
```elixir
%Mensaje{
  id: String.t(),
  emisor_id: String.t(),
  equipo_id: String.t() | nil,
  contenido: String.t(),
  timestamp: DateTime.t(),
  tipo: :normal | :anuncio | :sistema
}
```

#### Mentor
```elixir
%Mentor{
  id: String.t(),
  nombre: String.t(),
  especialidad: String.t(),
  equipos_asignados: [String.t()],
  disponible: boolean()  # false después de 3 equipos
}
```

### 3.2 Reglas de Negocio

**Validaciones de Equipo:**
- Nombre mínimo de 3 caracteres
- Nombre único en el sistema
- No puede tener más de un proyecto

**Validaciones de Participante:**
- Correo válido (contiene @ y .)
- Correo único en el sistema
- Solo puede estar en un equipo a la vez

**Validaciones de Proyecto:**
- Categorías permitidas: social, ambiental, educativo
- Estados permitidos: idea, desarrollo, finalizado
- Un equipo solo puede tener un proyecto

**Reglas de Mentoría:**
- Un mentor puede tener hasta 3 equipos
- Después de 3 equipos, el mentor no está disponible
- Solo mentores asignados pueden dar retroalimentación

---

## 4. Capa de Servicios

### 4.1 GestionEquipos
**Responsabilidad:** Gestionar el ciclo de vida de los equipos.

**Operaciones principales:**
- `crear_equipo(nombre)` - Crea un nuevo equipo
- `listar_equipos()` - Lista todos los equipos con estadísticas
- `ver_equipo(nombre_o_id)` - Muestra detalles completos
- `unir_participante_a_equipo(participante_id, nombre_equipo)` - Asigna participante

**Flujo de creación de equipo:**
```
1. Validar nombre (longitud, unicidad)
2. Generar ID único
3. Crear entidad Equipo
4. Persistir en repositorio
5. Retornar resultado
```

### 4.2 GestionParticipantes
**Responsabilidad:** Administrar participantes del sistema.

**Operaciones principales:**
- `registrar(nombre, correo, rol)` - Registra nuevo participante
- `listar_participantes()` - Lista con información de equipos
- `ver_participante(correo)` - Detalles del participante

### 4.3 GestionProyectos
**Responsabilidad:** Gestionar proyectos de equipos.

**Operaciones principales:**
- `registrar_proyecto(equipo_id, titulo, descripcion, categoria)`
- `actualizar_avance(equipo_id, texto_avance)`
- `cambiar_estado(equipo_id, nuevo_estado)`
- `ver_proyecto(nombre_equipo)`

### 4.4 ChatService
**Responsabilidad:** Sistema de mensajería.

**Operaciones principales:**
- `enviar_mensaje(participante_id, contenido)`
- `enviar_anuncio(organizador_id, contenido)`
- `ver_chat(nombre_equipo, limite)`
- `estadisticas_equipo(nombre_equipo)`

### 4.5 MentoriaService
**Responsabilidad:** Sistema de mentoría.

**Operaciones principales:**
- `registrar_mentor(nombre, especialidad)`
- `asignar_mentor_a_equipo(mentor_id, nombre_equipo)`
- `dar_feedback(mentor_id, nombre_equipo, comentario)`
- `listar_mentores_disponibles()`

---

## 5. Capa de Adaptadores

### 5.1 Persistencia (JSON)

**Patrón de Repositorio:**
Cada entidad tiene su propio repositorio que implementa:
- `guardar(entidad)` - Inserta nueva entidad
- `actualizar(entidad)` - Modifica entidad existente
- `leer_todos()` - Recupera todas las entidades
- `obtener_por_id(id)` - Búsqueda por ID
- `eliminar(id)` - Elimina entidad

**Conversión JSON:**
```elixir
# Struct → JSON
struct_a_mapa(entidad) → Jason.encode!() → File.write!()

# JSON → Struct
File.read!() → Jason.decode!() → mapa_a_struct()
```

**Manejo de Fechas:**
```elixir
# Guardar
DateTime.to_iso8601(datetime) → "2024-11-06T14:30:45Z"

# Leer
DateTime.from_iso8601(string) → {:ok, datetime, offset}
```

### 5.2 CLI (Interfaz de Línea de Comandos)

**Componentes:**

1. **Parser** (`cli/parser.ex`)
   - Interpreta comandos del usuario
   - Convierte strings en tuplas estructuradas
   - Maneja validaciones sintácticas

2. **Comandos** (`cli/comandos.ex`)
   - Ejecuta comandos parseados
   - Conecta con Services
   - Maneja errores y respuestas

3. **UI** (`cli/ui.ex`)
   - Formatea salidas con colores
   - Presenta información estructurada
   - Mejora experiencia de usuario

**Flujo de ejecución:**
```
Usuario → Parser → Comandos → Services → Domain
                                      ↓
                           Repositorios → JSON
```

---

## 6. Persistencia y Datos

### 6.1 Formato de Archivos JSON

**Ejemplo: equipos.json**
```json
[
  {
    "id": "a1b2c3d4",
    "nombre": "Los Innovadores",
    "integrantes": ["p1e2f3g4", "h5i6j7k8"],
    "proyecto_id": "m9n0o1p2",
    "mentores_ids": ["q3r4s5t6"],
    "fecha_creacion": "2024-11-06T10:30:00Z",
    "estado": "activo"
  }
]
```

**Ejemplo: proyectos.json**
```json
[
  {
    "id": "m9n0o1p2",
    "equipo_id": "a1b2c3d4",
    "titulo": "EcoApp",
    "descripcion": "App para reciclaje inteligente",
    "categoria": "ambiental",
    "estado": "desarrollo",
    "avances": [
      {
        "texto": "Completado diseño UI",
        "fecha": "2024-11-06T12:00:00Z"
      }
    ],
    "retroalimentacion": [
      {
        "mentor_id": "q3r4s5t6",
        "comentario": "Excelente progreso",
        "fecha": "2024-11-06T15:00:00Z"
      }
    ],
    "fecha_creacion": "2024-11-06T11:00:00Z"
  }
]
```

### 6.2 Estrategia de Persistencia

**Ventajas:**
-  Sin dependencias de base de datos
-  Fácil de debuggear (texto plano)
-  Portable (copiar carpeta `data/`)
-  Suficiente para eventos de 48h

**Limitaciones:**
-  No soporta concurrencia de escritura
-  Carga completa en memoria
-  No hay transacciones

---

## 7. Comandos del Sistema

### 7.1 Gestión de Equipos
```bash
/teams                    # Listar todos los equipos
/teams create <nombre>    # Crear nuevo equipo
/team <nombre>            # Ver detalles de equipo
/join <equipo>            # Unirse a equipo
```

### 7.2 Participantes
```bash
/register <nombre> <correo>              # Registrar participante
/register-organizer <nombre> <correo>    # Registrar organizador
/participants                            # Listar participantes
/me <correo>                             # Ver mi información
```

### 7.3 Proyectos
```bash
/projects                                              # Listar proyectos
/project <equipo>                                      # Ver proyecto
/register-project <equipo> | <titulo> | <desc> | <categoria>
/progress <equipo> | <avance>                         # Actualizar avance
```

### 7.4 Chat
```bash
/chat <equipo>                    # Ver chat de equipo
/send <id> | <mensaje>            # Enviar mensaje
/announce <id> | <anuncio>        # Enviar anuncio (organizadores)
/announcements                    # Ver anuncios
```

### 7.5 Mentoría
```bash
/mentors                                  # Listar mentores
/register-mentor <nombre> <especialidad>  # Registrar mentor
/assign-mentor <id> | <equipo>            # Asignar mentor
/feedback <id> | <equipo> | <comentario>  # Dar feedback
```

### 7.6 Estadísticas
```bash
/stats              # Estadísticas generales
/stats <equipo>     # Estadísticas de equipo
```

### 7.7 Sistema
```bash
/help     # Mostrar ayuda
/clear    # Limpiar pantalla
/exit     # Salir del sistema
```

---

## 8. Compilación y Despliegue

### 8.1 Requisitos
- Elixir 1.18+ instalado
- Erlang/OTP 27+
- Mix (incluido con Elixir)

### 8.2 Instalación
```bash
# Clonar repositorio
git clone <url-repositorio>
cd hackathon

# Instalar dependencias
mix deps.get

# Compilar proyecto
mix compile
```

### 8.3 Ejecución

**Modo desarrollo:**
```bash
iex -S mix
```

**Modo producción (ejecutable):**
```bash
# Generar ejecutable
mix escript.build

# Ejecutar
escript hackathon      # Linux/Mac
escript.exe hackathon  # Windows
```

### 8.4 Pruebas
```bash
# Ejecutar todas las pruebas
mix test

# Ejecutar con cobertura
mix test --cover

# Ejecutar tests específicos
mix test test/domain/equipo_test.exs
```

---

## 9. Mantenimiento y Extensibilidad

### 9.1 Agregar Nueva Entidad

1. Crear struct en `domain/`
2. Crear repositorio en `adapters/persistencia/`
3. Crear service en `services/`
4. Agregar comandos CLI si es necesario

### 9.2 Agregar Nuevo Comando

1. Agregar parsing en `cli/parser.ex`
2. Agregar ejecución en `cli/comandos.ex`
3. Actualizar ayuda en `cli/ui.ex`

### 9.3 Migrar a Base de Datos

```elixir
# Reemplazar repositorios JSON por Ecto
defmodule Hackathon.Repo.EquipoRepo do
  import Ecto.Query
  alias Hackathon.Repo
  
  def leer_todos do
    Repo.all(Equipo)
  end
end
```

---

## 10. Seguridad

### 10.1 Validaciones Implementadas
-  Validación de formato de correo
-  Validación de longitud de nombres
-  Validación de unicidad (equipos, correos)
-  Validación de permisos (solo organizadores pueden anunciar)
-  Validación de asignaciones (mentor asignado puede dar feedback)

---

## 11. Troubleshooting

### 11.1 Problemas Comunes

**Error: "key :id not found"**
- Causa: Archivo JSON corrupto
- Solución: Eliminar archivo en `data/`

**Error: "module not found"**
- Causa: Dependencias no instaladas
- Solución: `mix deps.get`

**Caracteres raros en terminal**
- Causa: Codificación UTF-8
- Solución: `chcp 65001` (Windows)

### 11.2 Logs y Depuración

```bash
# Ver logs en desarrollo
iex -S mix

# Depuración con IEx.pry
import IEx
# En el código:
IEx.pry()
```

---

## 12. Glosario Técnico

- **Struct:** Estructura de datos inmutable en Elixir
- **Pattern Matching:** Coincidencia de patrones para desestructurar datos
- **Pipe Operator (|>):** Encadenamiento de funciones
- **Tuple:** Estructura de datos ordenada `{:ok, value}`
- **Atom:** Constante cuyo valor es su nombre `:activo`
- **GenServer:** Proceso servidor para estado mutable
- **Supervisor:** Proceso que supervisa y reinicia otros procesos

---

## 13. Referencias

- [Documentación Oficial de Elixir](https://elixir-lang.org/docs.html)
- [Guía de Estilo Elixir](https://github.com/christopheradams/elixir_style_guide)
- [Arquitectura Hexagonal](https://alistair.cockburn.us/hexagonal-architecture/)
- [Jason - Librería JSON](https://hexdocs.pm/jason/)

---