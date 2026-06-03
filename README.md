# Recursos UTS

## Carpeta `lib/`

La carpeta `lib/` contiene todo el código fuente de la aplicación Flutter. Está organizada siguiendo una arquitectura por capas:

### `main.dart`
Archivo principal que inicializa Firebase, configura el `Provider` como gestor de estado global y lanza la aplicación.

### `models/`
Define las clases de datos (DTOs) que representan las entidades del sistema:
- **Usuario** — datos personales, rol (admin/estudiante), estado activo/inactivo
- **Recurso** — ítems del inventario con nombre, icono, cantidad total, disponible y categoría (equipos, cables, otros)
- **Solicitud** — petición de préstamo hecha por un usuario con fechas, recurso y accesorios
- **Prestamo** — préstamo ya aprobado con estado (activo, devuelto, vencido)
- **Notificación** — alerta del sistema con tipo, mensaje y destinatario
- **Equipo** — equipo de cómputo individual dentro de un salón

### `providers/`
Contiene `app_provider.dart`, un `ChangeNotifier` que actúa como capa de estado central. Aquí se gestionan:
- Autenticación (inicio de sesión, registro, cierre)
- CRUD de usuarios, recursos, solicitudes, préstamos y notificaciones
- Lógica de negocio: aprobar/rechazar solicitudes, registrar devoluciones, generar alertas de vencimiento
- Sincronización con Firestore y fallback local ante fallos de conexión

### `screens/`
Agrupa las pantallas según el rol del usuario:
- **`admin/`** — panel de control, gestión de solicitudes, CRUD de recursos y salones, historial, escáner de barras
- **`user/`** — explorar recursos, solicitar préstamo, mis préstamos, perfil, notificaciones
- **`login/`** — inicio de sesión y registro de nuevos usuarios
- **`start/`** — splash screen de carga

### `services/`
Capa de acceso a datos externos:
- **`firestore_service.dart`** — operaciones CRUD contra Firebase Firestore (usuarios, recursos, solicitudes, préstamos, notificaciones)
- **`notificacion_service.dart`** — notificaciones push locales en el dispositivo

### `theme/`
Define la paleta de colores (`AppColors`), estilos de texto (`AppStyles`) y la configuración visual global de la interfaz.

### `utils/`
Contiene `icon_utils.dart`, un mapa que convierte nombres de icono en formato `String` (ej. `"computer"`, `"videocam"`) a objetos `IconData` de Flutter.

### `widgets/`
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
