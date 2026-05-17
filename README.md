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
- ""Dart 3.11.5** - Lenguaje
- **Provider** — Manejo de estado
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

```
lib/
├── main.dart                    # Punto de entrada
├── models/                      # Modelos de datos
│   ├── equipo.dart
│   ├── notificacion.dart
│   ├── prestamo.dart
│   ├── recurso.dart
│   ├── solicitud.dart
│   └── usuario.dart
├── providers/
│   └── app_provider.dart        # Estado central de la app
├── screens/
│   ├── admin/                   # Pantallas de administrador
│   ├── login/                   # Inicio de sesión y registro
│   ├── start/                   # Splash screen
│   └── user/                    # Pantallas de usuario
├── services/
│   └── notificacion_service.dart
├── theme/
│   └── app_theme.dart           # Paleta de colores y estilos
└── widgets/                     # Widgets reutilizables
```

## Credenciales de prueba

| Rol          | Correo             | Contraseña |
|-------------|--------------------|------------|
| Admin       | admin@uts.com      | admin123   |
| Usuario     | admin@correo.com   | 1234       |

## Licencia

Este proyecto fue desarrollado con fines académicos para las Unidades Tecnológicas de Santander.
