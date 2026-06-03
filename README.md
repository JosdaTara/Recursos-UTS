# Recursos UTS

Sistema de préstamo de recursos tecnológicos para las Unidades Tecnológicas de Santander (UTS). Desarrollado en **Flutter** con gestión en memoria y dos roles: **Administrador** y **Usuario**.

## Capturas de pantalla

*(Agrega aquí capturas de la app)*

## Funcionalidades

### Rol Usuario
- Inicio de sesión y registro
- Visualizar recursos disponibles (computadores por salón, cables, accesorios)
- Solicitar préstamo de recursos con selección de fechas y horarios
- Apartar equipo de cómputo (salón + equipo)
- Ver historial de préstamos propios
- Perfil con foto personalizable
- Notificaciones de alertas (préstamos por vencer, vencidos)

### Rol Administrador
- Panel principal con resumen estadístico (solicitudes pendientes, préstamos activos, recursos disponibles, usuarios)
- Alertas visuales para solicitudes pendientes, préstamos por vencer y activos
- Gestión de solicitudes (aprobar / rechazar)
- CRUD de recursos del inventario
- Gestión de usuarios (activar / desactivar)
- Historial completo de préstamos
- Escáner de código de barras para registrar devoluciones
- Notificaciones del sistema

## Tecnologías usadas

- **Flutter 3.41.7** — Framework de UI multiplataforma
- **Dart 3.11.5** - Lenguaje
- **Provider** — Manejo de estado
- **Firebase Auth** — Autenticación de usuarios
- **Cloud Firestore** — Base de datos en la nube
- **Mobile Scanner** — Escaneo de códigos de barras
- **Flutter Local Notifications** — Notificaciones push locales
- **Image Picker** — Selección de fotos de perfil

## Requisitos

- Flutter SDK >= 3.0
- Dart >= 3.0
- Dispositivo o emulador Android / iOS

## Instalación

```bash
# Clonar el repositorio
git clone https://github.com/JosdaTara/Recursos-UTS.git

# Entrar al directorio
cd Recursos-UTS

# Obtener dependencias
flutter pub get

# Ejecutar en modo debug
flutter run
```

## Estructura del proyecto

La lógica de la aplicación se encuentra en la carpeta `lib/`, organizada de la siguiente manera:

```
lib/
├── main.dart                    # Punto de entrada de la app
│                                # Inicializa Firebase, Provider y carga inicial
│
├── models/                      # Modelos de datos (DTOs)
│   ├── equipo.dart              # Equipo de cómputo dentro de un salón
│   ├── notificacion.dart        # Notificación del sistema (solicitud, aprobado, vencido)
│   ├── prestamo.dart            # Préstamo activo, devuelto o vencido
│   ├── recurso.dart             # Recurso del inventario (categoría, icono, disponibilidad)
│   ├── solicitud.dart           # Solicitud de préstamo hecha por un usuario
│   └── usuario.dart             # Usuario registrado (admin o estudiante)
│
├── providers/
│   └── app_provider.dart        # Estado central con ChangeNotifier
│                                # Maneja usuarios, recursos, solicitudes, préstamos,
│                                # notificaciones, autenticación y toda la lógica de negocio
│
├── screens/                     # Pantallas de la interfaz
│   ├── admin/                   # Pantallas exclusivas del administrador
│   │   ├── escaner_screen.dart           # Escáner de código de barras
│   │   ├── gestion_recursos_screen.dart  # CRUD de recursos y salones
│   │   ├── gestion_usuarios_screen.dart  # Gestión de usuarios
│   │   ├── historial_screen.dart         # Historial de préstamos
│   │   ├── home_admin_screen.dart        # Panel principal con estadísticas
│   │   └── solicitudes_screen.dart       # Aprobar/rechazar solicitudes
│   ├── login/                   # Autenticación
│   │   ├── login_screen.dart             # Inicio de sesión
│   │   └── register_screen.dart          # Registro de nuevo usuario
│   ├── start/
│   │   └── splash_screen.dart            # Pantalla de carga inicial
│   └── user/                    # Pantallas del usuario común
│       ├── home_screen.dart              # Menú principal del usuario
│       ├── menu_screen.dart              # Menú lateral de navegación
│       ├── mis_prestamos_screen.dart     # Historial de préstamos propios
│       ├── notificaciones_screen.dart    # Bandeja de notificaciones
│       ├── perfil_screen.dart            # Perfil con foto personalizable
│       ├── recursos_screen.dart          # Explorar recursos disponibles
│       └── solicitar_prestamo_screen.dart# Formulario de solicitud
│
├── services/                    # Capa de acceso a datos y servicios externos
│   ├── firestore_service.dart   # CRUD contra Firebase Firestore
│   └── notificacion_service.dart# Notificaciones push locales
│
├── theme/
│   └── app_theme.dart           # Paleta de colores, estilos de texto y temas
│
├── utils/
│   └── icon_utils.dart          # Mapa de nombres de icono (String → IconData)
│
└── widgets/                     # Componentes reutilizables
    ├── background_scaffold.dart         # Fondo con gradiente
    ├── custom_back_button.dart          # Botón de retroceso personalizado
    ├── estado_badge.dart                # Badge de estado (activo/inactivo/pendiente)
    ├── filter_chip_row.dart             # Fila de chips para filtrar listas
    ├── glass_card.dart                  # Tarjeta con estilo glassmorphism
    ├── header_with_back.dart            # Encabezado con botón de retroceso
    ├── info_row.dart                    # Fila de información (icono + label + valor)
    ├── section_divider.dart             # Divisor de sección con título
    └── stat_card.dart                   # Tarjeta de estadística numérica
```

## Licencia

Este proyecto fue desarrollado con fines académicos para las Unidades Tecnológicas de Santander.
