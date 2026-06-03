# Explicación del Código — Sistema de Préstamos de Recursos Informáticos

---

## 1. Arquitectura General

El proyecto sigue el patrón **Provider** (ChangeNotifier) de Flutter para manejo de estado global. La aplicación se conecta a **Firebase Auth** (autenticación) y **Cloud Firestore** (base de datos NoSQL en la nube).

```
main.dart
├── providers/app_provider.dart   ← Estado global (ChangeNotifier)
├── models/                        ← 6 modelos de datos
├── services/                      ← 2 servicios (Firestore + notif. locales)
├── screens/                       ← 15 pantallas
│   ├── start/     (1 pantalla)
│   ├── login/     (2 pantallas)
│   ├── user/      (6 pantallas)
│   └── admin/     (6 pantallas)
├── widgets/                       ← 9 widgets reutilizables
├── theme/                         ← 1 archivo de tema
└── utils/                         ← 1 archivo de utilería
```

---

## 2. Flujo de Datos

**Firestore Collections:** `usuarios`, `recursos`, `solicitudes`, `prestamos`, `notificaciones`

1. `main.dart` crea `AppProvider` (ChangeNotifier).
2. El constructor `AppProvider()` llama a `_cargarDatos()`, que carga todas las colecciones de Firestore de forma independiente (cada una con su propio try-catch, para que una falla no bloquee las demás).
3. Si Firestore falla, usa datos locales de respaldo (`_initDataLocalUsuarios()`, `_initDataLocalRecursos()`).
4. Cada pantalla usa `context.watch<AppProvider>()` para escuchar cambios y `context.read<AppProvider>()` para ejecutar acciones.
5. Cualquier modificación (agregar/editar/eliminar) se hace primero en memoria y luego en Firestore, y se llama a `notifyListeners()`.

---

## 3. Modelos (lib/models/)

### `usuario.dart`
- **Campos:** id, nombre, correo, password, documento, programa, activo, esAdmin
- `Usuario.fromFirestore()` con null safety en cada campo (fallback a `''` o `true`)
- `toFirestore()` convierte a `Map<String, dynamic>` para guardar en Firestore

### `recurso.dart`
- **Campos:** nombre, icono, total, disponible, categoria, codigoBarras, accesoriosIncluidos
- **Enum:** `CategoriaRecurso { todos, equipos, cables, otros }`
- `porcentajeDisponible` getter calcula `disponible / total`

### `solicitud.dart`
- **Campos:** id, usuarioNombre, documento, programa, recursoNombre, recursoIcono, accesorios, salon, equipo, fechaPrestamo, fechaDevolucion, fechaSolicitud, estado
- **Enum:** `EstadoSolicitud { pendiente, aprobada, rechazada }`
- Getters para formato de fechas: `fechaPrestamoStr`, `fechaDevolucionStr`, `fechaSolicitudStr` (con texto "Hoy"/"Ayer")

### `prestamo.dart`
- **Campos:** id, usuarioNombre, recursoNombre, recursoIcono, salon, equipo, accesorios, fechaPrestamo, fechaDevolucion, estado
- **Enum:** `EstadoPrestamo { activo, devuelto, vencido }`

### `notificacion.dart`
- **Campos:** id, tipo, titulo, mensaje, hora, fecha, leida, solicitudId, usuarioCorreo
- **Enum:** `TipoNotificacion { aprobado, recordatorio, vencido, solicitud }`

### `equipo.dart`
- Modelo simple para equipos dentro de salones: nombre, disponible (bool)

---

## 4. Provider (lib/providers/app_provider.dart) — 710 líneas

Heartbeat de toda la app. Es un `ChangeNotifier` con:

### Gestión de datos (constructor)
- `_cargarDatos()`: Carga secuencial de cada colección con try-catch individual. Al final llama a `_sincronizarComputadores()`, `_generarAlertasPrestamos()`, y `_verificarSesionGuardada()`.
- `refrescarDatos()`: Recarga todo (usado por pull-to-refresh).

### Datos locales de respaldo
- `_initDataLocalUsuarios()`: Crea admin por defecto.
- `_initDataLocalRecursos()`: Crea recursos base (COMPUTADOR, VIDEO BEAM, PARLANTES, CABLES, EXTENSIÓN).

### Siembra inicial
- `_sembrarSiVacio()`: Crea cuenta admin en Auth + Firestore, agrega recursos base solo si no existen (evita duplicados).

### Autenticación (6 métodos)
- `iniciarSesion()`: Firebase Auth + verifica usuario activo. Soporta "recordar sesión" (SharedPreferences).
- `registrarUsuario()`: Firebase Auth + guarda en Firestore.
- `olvideContrasena()`: Envía correo de restablecimiento.
- `cerrarSesion()`: Limpia sesión guardada.
- `_guardarSesion()` / `_verificarSesionGuardada()`: SharedPreferences.

### CRUD Recursos (5 métodos)
- `agregarRecurso()`, `editarRecurso()`, `eliminarRecurso()`: Modifican lista y Firestore.
- `recursoPorCodigo()`: Busca por código de barras (usado en escáner).
- `prestamoActivoPorRecurso()`: Busca si hay préstamo activo para ese recurso.
- `devolverPrestamo()`: Cambia estado a devuelto, incrementa disponibilidad.

### CRUD Salones (5 métodos) — todos async
- Salones almacenados en `Map<String, List<Equipo>>` en memoria (no en Firestore).
- `agregarSalon()`, `editarSalon()`, `eliminarSalon()`, `agregarEquipo()`, `eliminarEquipo()`.
- Todos llaman a `_sincronizarComputadores()` para mantener el conteo de PCs actualizado.

### Sincronización de COMPUTADOR (1 método)
- `_sincronizarComputadores()`: Cuenta PCs en salones, actualiza `total` y `disponible` del recurso COMPUTADOR en memoria y Firestore.

### CRUD Solicitudes (5 métodos)
- `agregarSolicitud()`: Crea solicitud + notificación al admin (sin `usuarioCorreo`).
- `aprobarSolicitud()`: Cambia estado, crea préstamo activo, descuenta disponibilidad, notifica al usuario (con `usuarioCorreo`).
- `rechazarSolicitud()`: Cambia estado, notifica al usuario.
- `aprobarSolicitudPorId()` / `rechazarSolicitudPorId()`: Usados desde notificaciones.

### Notificaciones (3 métodos)
- `marcarNotificacionLeida()`, `eliminarNotificacion()`: Con persistencia Firestore.
- `_marcarNotificacionSolicitudResuelta()`: Marca como leída la notificación de solicitud cuando se aprueba/rechaza.

### Alertas automáticas (2 métodos)
- `_generarAlertasPrestamos()`: Recorre préstamos activos. Si están vencidos: cambia estado, incrementa disponibilidad, notifica. Si vencen en <2h: notifica recordatorio.
- `actualizarAlertas()`: Ejecuta lo anterior.

### Estadísticas (2 métodos)
- `recursoMasPrestado()`: Cuenta préstamos + solicitudes aprobadas por recurso, devuelve nombre, cantidad, icono, porcentaje.
- `prestamosParaHistorial()`: Formatea todos los préstamos para mostrar en tabla.

### Getters computados (7)
- `solicitudesPendientes`, `prestamosActivos`, `usuariosActivos`, `recursosDisponibles`, `notificacionesNoLeidas` (filtra por `usuarioCorreo` para no-admins), `prestamosProximosAVencer` (<2h), `iconoPorRecurso()`.

---

## 5. Servicios (lib/services/)

### `firestore_service.dart` — Capa de abstracción de Firestore
- **Usuarios:** getUsuarios() (salta documentos dañados con try-catch por documento), setUsuario, deleteUsuario, getUsuarioPorCorreo, usuariosStream
- **Recursos:** getRecursos, setRecurso, deleteRecurso, actualizarDisponibilidad, recursosStream
- **Solicitudes:** getSolicitudes (ordenadas por fecha descendente), setSolicitud, updateSolicitudEstado, solicitudesStream
- **Préstamos:** getPrestamos, setPrestamo, updatePrestamoEstado, prestamosStream
- **Notificaciones:** getNotificaciones, setNotificacion, marcarNotificacionLeida, deleteNotificacion, marcarTodasLeidas

### `notificacion_service.dart` — Notificaciones push locales (Singleton)
- Inicializa `flutter_local_notifications` (Android + iOS).
- `mostrarNotificacion()`: Muestra notificación en el dispositivo.

---

## 6. Tema (lib/theme/app_theme.dart)

- **AppColors:** primary (#5A6000 verde oliva), primaryLight (#C8D400), bgDark (#3D4200), gradientOverlay.
- **AppStyles:** 6 estilos de texto predefinidos (titleWhite, subtitleWhite, whiteBold16, whiteBold13, white70_12, white54_11).

---

## 7. Widgets Reutilizables (lib/widgets/)

| Widget | Propósito |
|--------|-----------|
| `BackgroundScaffold` | Fondo con imagen + gradiente oscuro, usado en TODAS las pantallas |
| `GlassCard` | Tarjeta semitransparente estilo "vidrio" |
| `HeaderWithBack` | Encabezado con título y botón de retroceso |
| `CustomBackButton` | Botón de retroceso circular |
| `EstadoBadge` | Badge de estado (coloreado) |
| `FilterChipRow` | Fila de chips para filtros |
| `InfoRow` | Fila icono + label + valor (usada en modales de detalle) |
| `SectionDivider` | Título de sección con línea decorativa |
| `StatCard` | Tarjeta de estadística compacta |

---

## 8. Pantallas — Usuario (lib/screens/user/)

| Pantalla | Descripción |
|----------|-------------|
| `home_screen.dart` | Inicio: logo, bienvenida con nombre del usuario, badge de notificaciones, botón menú (+) |
| `menu_screen.dart` | Menú lateral con 4 opciones: Perfil, Solicitar Préstamo, Mis Préstamos, Ver Recursos |
| `perfil_screen.dart` | Foto (cámara/galería), datos personales, estadísticas de préstamos, historial |
| `solicitar_prestamo_screen.dart` | Selección de recurso (grid), fechas/hora, salón+equipo (para computador), accesorios (para equipos), confirmación |
| `mis_prestamos_screen.dart` | Lista de préstamos del usuario con filtros (TODOS/ACTIVOS/DEVUELTOS), estadísticas, detalle modal |
| `recursos_screen.dart` | Computadores por salón, EQUIPOS DISPONIBLES (VIDEO BEAM, PARLANTES), OTROS RECURSOS, con barras de progreso y filtro por categoría |
| `notificaciones_screen.dart` | Lista filtrada por `usuarioCorreo` (admin ve todas, usuario ve solo las suyas). Admin puede aprobar/rechazar desde aquí |

---

## 9. Pantallas — Administrador (lib/screens/admin/)

| Pantalla | Descripción |
|----------|-------------|
| `home_admin_screen.dart` | Dashboard: header con perfil, alertas (solicitudes pendientes, préstamos por vencer), resumen (4 tarjetas), recurso más prestado, 5 opciones de gestión |
| `solicitudes_screen.dart` | Gestión de solicitudes filtradas (PENDIENTES/APROBADAS/RECHAZADAS/ACTIVOS), detalle modal con botones APROBAR/RECHAZAR, y REGISTRAR DEVOLUCIÓN para activos |
| `gestion_recursos_screen.dart` | Dos pestañas: RECURSOS (lista CRUD con editar/eliminar, formulario modal para agregar/editar con nombre, total, disponible, código, accesorios) y SALONES (CRUD con equipos, cada equipo se puede eliminar) |
| `gestion_usuarios_screen.dart` | Búsqueda + filtros (TODOS/ACTIVOS/INACTIVOS), lista con badge de estado y conteo de vencidos, detalle modal con datos, estadísticas, historial y botón ACTIVAR/DESACTIVAR |
| `historial_screen.dart` | Todos los préstamos con búsqueda, filtros (TODOS/ACTIVOS/DEVUELTOS/VENCIDOS), tarjetas resumen, recurso más prestado |
| `escaner_screen.dart` | Cámara con MobileScanner, detecta código de barras, busca recurso y préstamo activo, muestra resultado y permite registrar devolución |

---

## 10. Pantallas de Inicio (lib/screens/start/ + login/)

| Pantalla | Descripción |
|----------|-------------|
| `splash_screen.dart` | Pantalla de bienvenida con animaciones secuenciales (logo fade+scale, texto slide, botones slide). Botones: INICIAR SESIÓN y REGISTRARSE |
| `login_screen.dart` | Formulario de login con animación. Campos: correo, contraseña (con visibilidad toggle). Checkbox "Mantener sesión". Link "¿Olvidó su contraseña?". Valida contra Firebase Auth, redirige a `/homeAdmin` o `/home` |
| `register_screen.dart` | Formulario de registro con animación. Campos: nombre, correo, documento, programa (dropdown), contraseña, confirmar. Validaciones: campos completos, correo válido, contraseñas coinciden |

---

## 11. main.dart (Punto de Entrada)

- Inicializa Firebase, `NotificacionService`, crea `AppProvider` con Provider.
- Define rutas con nombre (10 rutas, de `/` a `/homeAdmin`).
- Tema con `ColorScheme.fromSeed` color institucional #5A6000.

---

## 12. Flujo Completo de una Solicitud de Préstamo

1. **Usuario** → `SplashScreen` → `RegisterScreen` (se registra) o `LoginScreen` (inicia sesión)
2. **Usuario** → `HomeScreen` → `MenuScreen` → `SolicitarPrestamoScreen`
3. Selecciona recurso (ej: COMPUTADOR), salón, equipo, fechas, confirma
4. `agregarSolicitud()` guarda en Firestore + crea notificación visible para admin
5. **Admin** → `HomeAdminScreen` (ve badge de notificación + alerta "1 solicitud pendiente")
6. Admin abre `SolicitudesScreen` o `NotificacionesScreen`
7. Admin toca la solicitud → modal con detalle → presiona APROBAR
8. `aprobarSolicitud()`: cambia estado, crea `Prestamo` activo, descuenta disponibilidad, notifica al usuario
9. **Usuario** → `NotificacionesScreen` ve "PRÉSTAMO APROBADO" / `MisPrestamosScreen` ve el préstamo ACTIVO
10. **Admin** registra devolución desde `SolicitudesScreen` (filtro ACTIVOS), `EscanerScreen`, o `HistorialScreen`
11. `devolverPrestamo()`: cambia estado a devuelto, incrementa disponibilidad

---

## 13. Manejo de Errores y Respaldo

- Cada colección se carga en su propio bloque try-catch en `_cargarDatos()`.
- Si `getUsuarios()` falla → `_initDataLocalUsuarios()` (admin por defecto).
- Si `getRecursos()` falla → `_initDataLocalRecursos()` (recursos base).
- Las colecciones solicitudes/prestamos/notificaciones se cargan con try-catch (si fallan, quedan vacías).
- `getUsuarios()` salta documentos mal formados (try-catch por documento) para evitar que un documento corrupto bloquee toda la carga.

---

## 14. Puntos Clave para la Presentación

- **Provider Pattern** — Estado global reactivo
- **Firebase Auth + Firestore** — Autenticación y base de datos en la nube
- **Arquitectura modular** — Modelos, servicios, widgets separados
- **Fallback local** — Sin Firebase los datos base siguen funcionando
- **Notificaciones push** — Locales con flutter_local_notifications
- **Roles** — Admin y Usuario con vistas y acciones diferenciadas
- **Sincronización dinámica** — COMPUTADOR se recalcula según PCs en salones
- **Código de barras** — Escáner integrado para gestión de inventario
- **Alertas automáticas** — Vencidos y próximos a vencer se detectan al cargar datos
- **Persistencia de sesión** — SharedPreferences para "recordar sesión"
