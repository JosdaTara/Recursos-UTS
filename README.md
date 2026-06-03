# Recursos UTS

## Carpeta `lib/`

La carpeta `lib/` contiene todo el código fuente de la aplicación Flutter. Está organizada siguiendo una arquitectura por capas:

### `main.dart`
*Archivo: `lib/main.dart`*

Punto de entrada de la aplicación. Inicializa Firebase, configura el `Provider` como gestor de estado global y lanza la app.

### `models/`
*Archivos: `lib/models/equipo.dart`, `notificacion.dart`, `prestamo.dart`, `recurso.dart`, `solicitud.dart`, `usuario.dart`*

Define las clases de datos (DTOs) que representan las entidades del sistema:
- **Usuario** — datos personales, rol (admin/estudiante), estado activo/inactivo
- **Recurso** — ítems del inventario con nombre, icono, cantidad total, disponible y categoría (equipos, cables, otros)
- **Solicitud** — petición de préstamo hecha por un usuario con fechas, recurso y accesorios
- **Prestamo** — préstamo ya aprobado con estado (activo, devuelto, vencido)
- **Notificación** — alerta del sistema con tipo, mensaje y destinatario
- **Equipo** — equipo de cómputo individual dentro de un salón

### `providers/`
*Archivo: `lib/providers/app_provider.dart`*

Contiene `app_provider.dart`, un `ChangeNotifier` que actúa como capa de estado central. Aquí se gestionan:
- Autenticación (inicio de sesión, registro, cierre)
- CRUD de usuarios, recursos, solicitudes, préstamos y notificaciones
- Lógica de negocio: aprobar/rechazar solicitudes, registrar devoluciones, generar alertas de vencimiento
- Sincronización con Firestore y fallback local ante fallos de conexión

### `screens/`
*Carpetas: `admin/`, `user/`, `login/`, `start/`*

Agrupa las pantallas según el rol del usuario:
- **`admin/`** — `escaner_screen.dart`, `gestion_recursos_screen.dart`, `gestion_usuarios_screen.dart`, `historial_screen.dart`, `home_admin_screen.dart`, `solicitudes_screen.dart`
- **`user/`** — `home_screen.dart`, `menu_screen.dart`, `mis_prestamos_screen.dart`, `notificaciones_screen.dart`, `perfil_screen.dart`, `recursos_screen.dart`, `solicitar_prestamo_screen.dart`
- **`login/`** — `login_screen.dart`, `register_screen.dart`
- **`start/`** — `splash_screen.dart`

### `services/`
*Archivos: `lib/services/firestore_service.dart`, `notificacion_service.dart`*

Capa de acceso a datos externos:
- **`firestore_service.dart`** — operaciones CRUD contra Firebase Firestore (usuarios, recursos, solicitudes, préstamos, notificaciones)
- **`notificacion_service.dart`** — notificaciones push locales en el dispositivo

### `theme/`
*Archivo: `lib/theme/app_theme.dart`*

Define la paleta de colores (`AppColors`), estilos de texto (`AppStyles`) y la configuración visual global de la interfaz.

### `utils/`
*Archivo: `lib/utils/icon_utils.dart`*

Contiene `icon_utils.dart`, un mapa que convierte nombres de icono en formato `String` (ej. `"computer"`, `"videocam"`) a objetos `IconData` de Flutter.

### `widgets/`
*Archivos: `lib/widgets/background_scaffold.dart`, `custom_back_button.dart`, `estado_badge.dart`, `filter_chip_row.dart`, `glass_card.dart`, `header_with_back.dart`, `info_row.dart`, `section_divider.dart`, `stat_card.dart`*

Componentes visuales reutilizables: tarjetas con efecto glassmorphism (`GlassCard`), barras de filtros (`FilterChipRow`), indicadores de estado (`EstadoBadge`), encabezados con retroceso (`HeaderWithBack`), entre otros.

```
lib/
├── main.dart
├── models/
├── providers/
│   └── app_provider.dart
├── screens/
│   ├── admin/
│   ├── login/
│   ├── start/
│   └── user/
├── services/
├── theme/
├── utils/
└── widgets/
```
