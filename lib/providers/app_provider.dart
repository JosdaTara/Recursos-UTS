// Proveedor central de estado de la aplicación (ChangeNotifier).
// Administra toda la lógica de negocio en memoria: recursos, usuarios, solicitudes,
// préstamos, notificaciones y salones. Los componentes de la UI se suscriben
// mediante Provider para reaccionar a los cambios.
import 'package:flutter/material.dart';
import 'package:flutter_recursos_uts/models/usuario.dart';
import 'package:flutter_recursos_uts/models/recurso.dart';
import 'package:flutter_recursos_uts/models/prestamo.dart';
import 'package:flutter_recursos_uts/models/solicitud.dart';
import 'package:flutter_recursos_uts/models/notificacion.dart';
import 'package:flutter_recursos_uts/models/equipo.dart';
import 'package:flutter_recursos_uts/services/notificacion_service.dart';

class AppProvider extends ChangeNotifier {
  // --- Listas de datos en memoria ---
  List<Usuario> _usuarios = [];
  List<Recurso> _recursos = [];
  List<Solicitud> _solicitudes = [];
  List<Prestamo> _prestamos = [];
  List<Notificacion> _notificaciones = [];
  // Mapa de salones → lista de equipos de cómputo
  Map<String, List<Equipo>> _salones = {};
  // Mapa auxiliar para dropdowns (salón → nombres de equipos)
  final Map<String, List<String>> _salonesDropdown = {};
  // Set para evitar generar alertas duplicadas para un mismo préstamo
  final Set<String> _prestamosConAlerta = {};

  AppProvider() {
    _initData();
    _generarAlertasPrestamos(); // Genera alertas iniciales si hay préstamos por vencer/vencidos
  }

  // ─── Getters ───────────────────────────────────────────────
  List<Usuario> get usuarios => _usuarios;
  List<Recurso> get recursos => _recursos;
  List<Solicitud> get solicitudes => _solicitudes;
  List<Prestamo> get prestamos => _prestamos;
  List<Notificacion> get notificaciones => _notificaciones;
  Map<String, List<Equipo>> get salones => _salones;
  Map<String, List<String>> get salonesDropdown => _salonesDropdown;

  // Cantidad de solicitudes con estado pendiente
  int get solicitudesPendientes =>
      _solicitudes.where((s) => s.estado == EstadoSolicitud.pendiente).length;

  // Cantidad de préstamos actualmente activos
  int get prestamosActivos =>
      _prestamos.where((p) => p.estado == EstadoPrestamo.activo).length;

  // Cantidad de usuarios marcados como activos
  int get usuariosActivos =>
      _usuarios.where((u) => u.activo).length;

  // Suma total de recursos disponibles (incluye todos los tipos)
  int get recursosDisponibles =>
      _recursos.fold(0, (sum, r) => sum + r.disponible);

  // Notificaciones que el usuario aún no ha visto
  int get notificacionesNoLeidas =>
      _notificaciones.where((n) => !n.leida).length;

  // Préstamos activos cuya fecha de devolución está a menos de 2 horas
  int get prestamosProximosAVencer =>
      _prestamos.where((p) {
        if (p.estado != EstadoPrestamo.activo) return false;
        return p.fechaDevolucion.isBefore(
            DateTime.now().add(const Duration(hours: 2)));
      }).length;

  // ─── Métodos: Recursos ─────────────────────────────────────
  void agregarRecurso(Recurso r) {
    _recursos.add(r);
    notifyListeners();
  }

  void editarRecurso(int index, Recurso r) {
    if (index >= 0 && index < _recursos.length) {
      _recursos[index] = r;
      notifyListeners();
    }
  }

  void eliminarRecurso(int index) {
    if (index >= 0 && index < _recursos.length) {
      _recursos.removeAt(index);
      notifyListeners();
    }
  }

  // Busca un recurso por su código de barras (búsqueda case-insensitive)
  Recurso? recursoPorCodigo(String codigo) {
    try {
      return _recursos.firstWhere(
          (r) => r.codigoBarras?.toUpperCase() == codigo.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  // Busca un préstamo activo por el nombre del recurso (usado por el escáner)
  Prestamo? prestamoActivoPorRecurso(String recursoNombre) {
    try {
      return _prestamos.firstWhere((p) =>
          p.recursoNombre == recursoNombre &&
          p.estado == EstadoPrestamo.activo);
    } catch (_) {
      return null;
    }
  }

  // Marca un préstamo como devuelto y libera el recurso
  void devolverPrestamo(Prestamo prestamo) {
    final idx = _prestamos.indexOf(prestamo);
    if (idx == -1) return;
    _prestamos[idx].estado = EstadoPrestamo.devuelto;
    final recurso = _recursos.where((r) =>
        r.nombre == prestamo.recursoNombre).firstOrNull;
    if (recurso != null) {
      recurso.disponible++; // Incrementa el contador de disponibilidad
    }
    notifyListeners();
    actualizarAlertas(); // Vuelve a verificar alertas después de la devolución
  }
  
  // ─── Métodos: Usuarios ─────────────────────────────────────
  // Alterna el estado activo/inactivo de un usuario
  void toggleUsuarioActivo(int index) {
    if (index >= 0 && index < _usuarios.length) {
      _usuarios[index].activo = !_usuarios[index].activo;
      notifyListeners();
    }
  }

  // ─── Métodos: Solicitudes ──────────────────────────────────
  // Aprueba una solicitud: la marca como aprobada, crea un préstamo activo
  // y descuenta la disponibilidad del recurso
  void aprobarSolicitud(int index) {
    if (index >= 0 && index < _solicitudes.length) {
      _solicitudes[index].estado = EstadoSolicitud.aprobada;
      final s = _solicitudes[index];
      _prestamos.add(Prestamo(
        usuarioNombre: s.usuarioNombre,
        recursoNombre: s.recursoNombre,
        recursoIcono: s.recursoIcono,
        salon: s.salon,
        equipo: s.equipo,
        accesorios: List.from(s.accesorios),
        fechaPrestamo: s.fechaPrestamo,
        fechaDevolucion: s.fechaDevolucion,
        estado: EstadoPrestamo.activo,
      ));
      final recurso = _recursos.where((r) =>
          r.nombre == s.recursoNombre).firstOrNull;
      if (recurso != null && recurso.disponible > 0) {
        recurso.disponible--;
      }
      notifyListeners();
      actualizarAlertas(); // Verifica si el nuevo préstamo necesita alerta
    }
  }

  void rechazarSolicitud(int index) {
    if (index >= 0 && index < _solicitudes.length) {
      _solicitudes[index].estado = EstadoSolicitud.rechazada;
      notifyListeners();
    }
  }

  // ─── Métodos: Notificaciones ───────────────────────────────
  void marcarNotificacionLeida(int index) {
    if (index >= 0 && index < _notificaciones.length) {
      _notificaciones[index].leida = true;
      notifyListeners();
    }
  }

  void eliminarNotificacion(int index) {
    if (index >= 0 && index < _notificaciones.length) {
      _notificaciones.removeAt(index);
      notifyListeners();
    }
  }

  // Escanea todos los préstamos activos y genera notificaciones si:
  // - La fecha de devolución ya pasó → marca como vencido, libera recurso, crea alerta
  // - La fecha de devolución es dentro de las próximas 2h → crea recordatorio
  // Usa _prestamosConAlerta para evitar notificaciones duplicadas
  void _generarAlertasPrestamos() {
    final now = DateTime.now();
    final enDosHoras = now.add(const Duration(hours: 2));

    for (final p in _prestamos) {
      if (p.estado != EstadoPrestamo.activo) continue;
      final key = '${p.recursoNombre}_${p.usuarioNombre}';

      // Préstamo vencido
      if (p.fechaDevolucion.isBefore(now) && !_prestamosConAlerta.contains(key)) {
        p.estado = EstadoPrestamo.vencido;
        final recurso = _recursos.where((r) =>
            r.nombre == p.recursoNombre).firstOrNull;
        if (recurso != null) recurso.disponible++;
        _notificaciones.add(Notificacion(
          tipo: TipoNotificacion.vencido,
          titulo: 'Préstamo vencido',
          mensaje: '${p.recursoNombre} - ${p.usuarioNombre} venció el ${p.fechaDevolucionStr}.',
          hora: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        ));
        // También envía notificación al sistema operativo del celular
        NotificacionService().mostrarNotificacion(
          titulo: 'Préstamo vencido',
          cuerpo: '${p.recursoNombre} - ${p.usuarioNombre} venció el ${p.fechaDevolucionStr}.',
        );
        _prestamosConAlerta.add(key);
      // Préstamo próximo a vencer (menos de 2 horas)
      } else if (p.fechaDevolucion.isBefore(enDosHoras) &&
          p.fechaDevolucion.isAfter(now) &&
          !_prestamosConAlerta.contains(key)) {
        _notificaciones.add(Notificacion(
          tipo: TipoNotificacion.recordatorio,
          titulo: 'Devolución próxima',
          mensaje: '${p.recursoNombre} - ${p.usuarioNombre} debe devolverse antes de las '
              '${p.fechaDevolucion.hour.toString().padLeft(2, '0')}:${p.fechaDevolucion.minute.toString().padLeft(2, '0')}.',
          hora: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        ));
        NotificacionService().mostrarNotificacion(
          titulo: 'Devolución próxima',
          cuerpo: '${p.recursoNombre} - ${p.usuarioNombre} debe devolverse antes de las '
              '${p.fechaDevolucion.hour.toString().padLeft(2, '0')}:${p.fechaDevolucion.minute.toString().padLeft(2, '0')}.',
        );
        _prestamosConAlerta.add(key);
      }
    }
  }

  // Método público para disparar la verificación de alertas desde las pantallas
  void actualizarAlertas() {
    _generarAlertasPrestamos();
    notifyListeners();
  }

  // ─── Data inicial (hardcoded) ──────────────────────────────
  // Siembra datos de ejemplo para poder probar la app sin base de datos
  void _initData() {
    // Salones con sus equipos de cómputo
    _salones = {
      'SALÓN 101': [
        Equipo(nombre: 'PC-01', disponible: true),
        Equipo(nombre: 'PC-02', disponible: false),
        Equipo(nombre: 'PC-03', disponible: true),
        Equipo(nombre: 'PC-04', disponible: true),
        Equipo(nombre: 'PC-05', disponible: false),
      ],
      'SALÓN 102': [
        Equipo(nombre: 'PC-01', disponible: true),
        Equipo(nombre: 'PC-02', disponible: true),
        Equipo(nombre: 'PC-03', disponible: false),
      ],
      'SALÓN 103': [
        Equipo(nombre: 'PC-01', disponible: false),
        Equipo(nombre: 'PC-02', disponible: true),
        Equipo(nombre: 'PC-03', disponible: true),
        Equipo(nombre: 'PC-04', disponible: true),
      ],
    };

    // Dropdowns auxiliares para seleccionar equipo por salón
    _salonesDropdown['SALÓN 101'] = ['PC-01', 'PC-02', 'PC-03', 'PC-04', 'PC-05'];
    _salonesDropdown['SALÓN 102'] = ['PC-01', 'PC-02', 'PC-03'];
    _salonesDropdown['SALÓN 103'] = ['PC-01', 'PC-02', 'PC-03', 'PC-04'];

    // Recursos disponibles para préstamo
    _recursos = [
      Recurso(
          nombre: 'VIDEO BEAM',
          icono: Icons.videocam,
          total: 6,
          disponible: 4,
          categoria: CategoriaRecurso.equipos,
          codigoBarras: 'VB-001',
          accesoriosIncluidos: ['CABLE HDMI', 'CONTROL REMOTO', 'MALETA']),
      Recurso(
          nombre: 'PARLANTES',
          icono: Icons.speaker,
          total: 6,
          disponible: 5,
          categoria: CategoriaRecurso.equipos,
          codigoBarras: 'PAR-001',
          accesoriosIncluidos: ['CABLE RCA', 'MICRÓFONO INALÁMBRICO']),
      Recurso(
          nombre: 'CABLE HDMI',
          icono: Icons.cable,
          total: 8,
          disponible: 3,
          categoria: CategoriaRecurso.cables,
          codigoBarras: 'HDMI-001'),
      Recurso(
          nombre: 'CABLE RCA',
          icono: Icons.settings_input_composite,
          total: 6,
          disponible: 3,
          categoria: CategoriaRecurso.cables),
      Recurso(
          nombre: 'CABLE USB',
          icono: Icons.usb,
          total: 5,
          disponible: 2,
          categoria: CategoriaRecurso.cables),
      Recurso(
          nombre: 'EXTENSIÓN',
          icono: Icons.electrical_services,
          total: 8,
          disponible: 7,
          categoria: CategoriaRecurso.otros),
    ];

    // Usuarios de ejemplo
    _usuarios = [
      Usuario(
        nombre: 'Juan Pérez',
        correo: 'juan@correo.com',
        documento: '1234567890',
        programa: 'TECNOLOGÍA EN DESARROLLO DE SISTEMAS INFORMÁTICOS',
        activo: true,
      ),
      Usuario(
        nombre: 'María López',
        correo: 'maria@correo.com',
        documento: '9876543210',
        programa: 'TECNOLOGÍA EN GESTIÓN EMPRESARIAL',
        activo: true,
      ),
      Usuario(
        nombre: 'Carlos García',
        correo: 'carlos@correo.com',
        documento: '1122334455',
        programa: 'TECNOLOGÍA EN ELECTRÓNICA',
        activo: false,
      ),
      Usuario(
        nombre: 'Ana Martínez',
        correo: 'ana@correo.com',
        documento: '5544332211',
        programa: 'TECNOLOGÍA EN CONTABILIDAD SISTEMATIZADA',
        activo: true,
      ),
      Usuario(
        nombre: 'Pedro Ruiz',
        correo: 'pedro@correo.com',
        documento: '6677889900',
        programa: 'TECNOLOGÍA EN LOGÍSTICA',
        activo: false,
      ),
    ];

    // Préstamos de ejemplo (activos, devueltos y vencidos)
    _prestamos = [
      Prestamo(
        usuarioNombre: 'Juan Pérez',
        recursoNombre: 'COMPUTADOR 001',
        recursoIcono: Icons.computer,
        salon: 'SALÓN 101',
        equipo: 'PC-03',
        fechaPrestamo: DateTime(2026, 4, 10, 15, 0),
        fechaDevolucion: DateTime(2026, 4, 10, 18, 0),
        estado: EstadoPrestamo.activo,
      ),
      Prestamo(
        usuarioNombre: 'María López',
        recursoNombre: 'VIDEO BEAM',
        recursoIcono: Icons.videocam,
        accesorios: ['CABLE HDMI', 'EXTENSIÓN'],
        fechaPrestamo: DateTime(2026, 4, 9, 10, 0),
        fechaDevolucion: DateTime(2026, 4, 11, 13, 30),
        estado: EstadoPrestamo.devuelto,
      ),
      Prestamo(
        usuarioNombre: 'Carlos García',
        recursoNombre: 'PARLANTES',
        recursoIcono: Icons.speaker,
        accesorios: ['CABLE RCA'],
        fechaPrestamo: DateTime(2026, 4, 7, 8, 0),
        fechaDevolucion: DateTime(2026, 4, 7, 12, 0),
        estado: EstadoPrestamo.vencido,
      ),
    ];

    // Solicitudes de préstamo en varios estados
    _solicitudes = [
      Solicitud(
        usuarioNombre: 'Juan Pérez',
        documento: '1234567890',
        programa: 'TECNOLOGÍA EN DESARROLLO DE SISTEMAS INFORMÁTICOS',
        recursoNombre: 'VIDEO BEAM',
        recursoIcono: Icons.videocam,
        accesorios: ['CABLE HDMI', 'EXTENSIÓN'],
        fechaPrestamo: DateTime(2026, 5, 8, 9, 0),
        fechaDevolucion: DateTime(2026, 5, 8, 12, 0),
        fechaSolicitud: DateTime(2026, 5, 12, 7, 30),
        estado: EstadoSolicitud.pendiente,
      ),
      Solicitud(
        usuarioNombre: 'María López',
        documento: '9876543210',
        programa: 'TECNOLOGÍA EN GESTIÓN EMPRESARIAL',
        recursoNombre: 'PARLANTES',
        recursoIcono: Icons.speaker,
        accesorios: ['CABLE RCA'],
        fechaPrestamo: DateTime(2026, 5, 8, 14, 0),
        fechaDevolucion: DateTime(2026, 5, 8, 17, 0),
        fechaSolicitud: DateTime(2026, 5, 12, 8, 15),
        estado: EstadoSolicitud.pendiente,
      ),
      Solicitud(
        usuarioNombre: 'Carlos García',
        documento: '1122334455',
        programa: 'TECNOLOGÍA EN ELECTRÓNICA',
        recursoNombre: 'COMPUTADOR',
        recursoIcono: Icons.computer,
        salon: 'SALÓN 101',
        equipo: 'PC-03',
        fechaPrestamo: DateTime(2026, 5, 8, 10, 0),
        fechaDevolucion: DateTime(2026, 5, 8, 13, 0),
        fechaSolicitud: DateTime(2026, 5, 11, 16, 0),
        estado: EstadoSolicitud.pendiente,
      ),
      Solicitud(
        usuarioNombre: 'Ana Martínez',
        documento: '5544332211',
        programa: 'TECNOLOGÍA EN CONTABILIDAD SISTEMATIZADA',
        recursoNombre: 'CABLE HDMI',
        recursoIcono: Icons.cable,
        fechaPrestamo: DateTime(2026, 5, 7, 8, 0),
        fechaDevolucion: DateTime(2026, 5, 7, 10, 0),
        fechaSolicitud: DateTime(2026, 5, 7, 7, 0),
        estado: EstadoSolicitud.aprobada,
      ),
      Solicitud(
        usuarioNombre: 'Pedro Ruiz',
        documento: '6677889900',
        programa: 'TECNOLOGÍA EN LOGÍSTICA',
        recursoNombre: 'VIDEO BEAM',
        recursoIcono: Icons.videocam,
        accesorios: ['CABLE RCA'],
        fechaPrestamo: DateTime(2026, 5, 6, 15, 0),
        fechaDevolucion: DateTime(2026, 5, 6, 18, 0),
        fechaSolicitud: DateTime(2026, 5, 6, 14, 0),
        estado: EstadoSolicitud.rechazada,
      ),
    ];

    // Notificaciones iniciales de ejemplo
    _notificaciones = [
      Notificacion(
        tipo: TipoNotificacion.aprobado,
        titulo: 'Préstamo aprobado',
        mensaje: 'Tu solicitud del COMPUTADOR 001 fue aprobada.',
        hora: 'Hoy, 3:00 PM',
        leida: false,
      ),
      Notificacion(
        tipo: TipoNotificacion.recordatorio,
        titulo: 'Devolución próxima',
        mensaje: 'Recuerda devolver el VIDEOBEAM mañana a la 1:30 PM.',
        hora: 'Hoy, 12:00 PM',
        leida: false,
      ),
      Notificacion(
        tipo: TipoNotificacion.vencido,
        titulo: 'Préstamo vencido',
        mensaje: 'El plazo del CABLE HDMI venció. Por favor devuélvelo.',
        hora: 'Ayer, 5:00 PM',
        leida: true,
      ),
    ];
  }

  // Calcula estadísticas del recurso más prestado (nombre, cantidad, icono, porcentaje)
  Map<String, dynamic> recursoMasPrestado() {
    final Map<String, int> conteo = {};
    final Map<String, IconData> iconos = {};
    for (final p in _prestamos) {
      conteo[p.recursoNombre] = (conteo[p.recursoNombre] ?? 0) + 1;
      iconos[p.recursoNombre] = p.recursoIcono;
    }
    for (final s in _solicitudes) {
      if (s.estado == EstadoSolicitud.aprobada) {
        conteo[s.recursoNombre] = (conteo[s.recursoNombre] ?? 0) + 1;
        iconos[s.recursoNombre] = s.recursoIcono;
      }
    }
    String mas = conteo.keys.first;
    conteo.forEach((k, v) {
      if (v > conteo[mas]!) mas = k;
    });
    final total = _prestamos.length +
        _solicitudes.where((s) => s.estado == EstadoSolicitud.aprobada).length;
    return {
      'nombre': mas,
      'cantidad': conteo[mas],
      'icono': iconos[mas],
      'porcentaje': total > 0 ? conteo[mas]! / total : 0.0,
    };
  }

  // Convierte la lista de préstamos en un formato apto para mostrar en el historial
  List<Map<String, dynamic>> prestamosParaHistorial() {
    return _prestamos.map((p) => {
      'usuario': p.usuarioNombre,
      'recurso': p.recursoNombre,
      'salon': p.salon,
      'equipo': p.equipo,
      'accesorios': p.accesorios,
      'fechaPrestamo': p.fechaPrestamoStr,
      'horaPrestamo':
          '${p.fechaPrestamo.hour.toString().padLeft(2, '0')}:${p.fechaPrestamo.minute.toString().padLeft(2, '0')}',
      'fechaDevolucion': p.fechaDevolucionStr,
      'horaDevolucion':
          '${p.fechaDevolucion.hour.toString().padLeft(2, '0')}:${p.fechaDevolucion.minute.toString().padLeft(2, '0')}',
      'estado': p.estado.name.toUpperCase(),
      'icono': p.recursoIcono,
    }).toList();
  }
}
