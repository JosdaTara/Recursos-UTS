import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_recursos_uts/models/usuario.dart';
import 'package:flutter_recursos_uts/models/recurso.dart';
import 'package:flutter_recursos_uts/models/prestamo.dart';
import 'package:flutter_recursos_uts/models/solicitud.dart';
import 'package:flutter_recursos_uts/models/notificacion.dart';
import 'package:flutter_recursos_uts/models/equipo.dart';
import 'package:flutter_recursos_uts/services/notificacion_service.dart';
import 'package:flutter_recursos_uts/services/firestore_service.dart';

class AppProvider extends ChangeNotifier {
  final FirestoreService _fs = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Usuario? _usuarioActual;
  bool _sesionIniciada = false;

  Usuario? get usuarioActual => _usuarioActual;
  bool get sesionIniciada => _sesionIniciada;
  bool get esAdmin => _usuarioActual?.esAdmin ?? false;

  List<Usuario> _usuarios = [];
  List<Recurso> _recursos = [];
  List<Solicitud> _solicitudes = [];
  List<Prestamo> _prestamos = [];
  List<Notificacion> _notificaciones = [];
  Map<String, List<Equipo>> _salones = {};
  final Map<String, List<String>> _salonesDropdown = {};
  final Set<String> _prestamosConAlerta = {};
  bool _cargando = true;

  AppProvider() {
    _cargarDatos();
  }

  bool get cargando => _cargando;

  List<Usuario> get usuarios => _usuarios;
  List<Recurso> get recursos => _recursos;
  List<Solicitud> get solicitudes => _solicitudes;
  List<Prestamo> get prestamos => _prestamos;
  List<Notificacion> get notificaciones => _notificaciones;
  Map<String, List<Equipo>> get salones => _salones;
  Map<String, List<String>> get salonesDropdown => _salonesDropdown;

  int get solicitudesPendientes =>
      _solicitudes.where((s) => s.estado == EstadoSolicitud.pendiente).length;

  int get prestamosActivos =>
      _prestamos.where((p) => p.estado == EstadoPrestamo.activo).length;

  int get usuariosActivos =>
      _usuarios.where((u) => u.activo).length;

  int get recursosDisponibles =>
      _recursos.fold(0, (sum, r) => sum + r.disponible);

  String iconoPorRecurso(String nombre) {
    final n = nombre.trim().toUpperCase();
    final r = _recursos.where((r) => r.nombre.trim().toUpperCase() == n).firstOrNull;
    return r?.icono ?? 'inventory_2';
  }

  int get notificacionesNoLeidas {
    if (_usuarioActual?.esAdmin == true) {
      return _notificaciones.where((n) => !n.leida).length;
    }
    return _notificaciones.where((n) =>
        !n.leida && n.usuarioCorreo == _usuarioActual?.correo).length;
  }

  int get prestamosProximosAVencer =>
      _prestamos.where((p) {
        if (p.estado != EstadoPrestamo.activo) return false;
        return p.fechaDevolucion.isBefore(
            DateTime.now().add(const Duration(hours: 2)));
      }).length;

  // ─── AUTENTICACIÓN ─────────────────────────────────────────
  Future<String?> iniciarSesion(String correo, String password,
      {bool recordar = false}) async {
    try {
      await _auth.signInWithEmailAndPassword(
          email: correo, password: password);
      final user = _auth.currentUser;
      if (user == null) return 'Error al iniciar sesión';
      _usuarioActual = _usuarios.where((u) => u.correo == correo).firstOrNull;
      _usuarioActual ??= Usuario(
        correo: correo,
        nombre: user.displayName ?? correo,
        documento: '',
        programa: '',
      );
      if (!_usuarioActual!.activo) {
        await _auth.signOut();
        _usuarioActual = null;
        return 'Tu cuenta está desactivada';
      }
      _sesionIniciada = true;
      if (recordar) await _guardarSesion(correo);
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found': msg = 'Correo no registrado'; break;
        case 'wrong-password': msg = 'Contraseña incorrecta'; break;
        case 'invalid-credential': msg = 'Correo o contraseña incorrectos'; break;
        case 'too-many-requests': msg = 'Demasiados intentos. Espera un momento'; break;
        default: msg = 'Error al iniciar sesión'; break;
      }
      return msg;
    } catch (_) {
      return 'Error de conexión';
    }
  }

  Future<String?> registrarUsuario(Usuario u, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: u.correo, password: password);
      await _auth.currentUser?.updateDisplayName(u.nombre);
      _usuarios.add(u);
      await _fs.setUsuario(u);
      _usuarioActual = u;
      _sesionIniciada = true;
      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use': msg = 'Este correo ya está registrado'; break;
        case 'weak-password': msg = 'La contraseña debe tener al menos 6 caracteres'; break;
        default: msg = 'Error al registrarse'; break;
      }
      return msg;
    } catch (_) {
      return 'Error de conexión';
    }
  }

  Future<String?> olvideContrasena(String correo) async {
    try {
      await _auth.sendPasswordResetEmail(email: correo);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return 'Correo no registrado';
      return 'Error al enviar el correo';
    } catch (_) {
      return 'Error de conexión';
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
    _usuarioActual = null;
    _sesionIniciada = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sesion_correo');
    notifyListeners();
  }

  Future<void> _guardarSesion(String correo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sesion_correo', correo);
  }

  Future<void> _verificarSesionGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final correo = prefs.getString('sesion_correo');
    if (correo == null) return;
    final user = _usuarios.where((u) => u.correo == correo).firstOrNull;
    if (user != null && user.activo) {
      _usuarioActual = user;
      _sesionIniciada = true;
    }
  }

  Future<void> _cargarDatos() async {
    _salones = {
      'SALÓN 101': [
        Equipo(nombre: 'PC-01', disponible: true),
        Equipo(nombre: 'PC-02', disponible: true),
        Equipo(nombre: 'PC-03', disponible: true),
        Equipo(nombre: 'PC-04', disponible: true),
        Equipo(nombre: 'PC-05', disponible: true),
      ],
      'SALÓN 102': [
        Equipo(nombre: 'PC-01', disponible: true),
        Equipo(nombre: 'PC-02', disponible: true),
        Equipo(nombre: 'PC-03', disponible: true),
      ],
      'SALÓN 103': [
        Equipo(nombre: 'PC-01', disponible: true),
        Equipo(nombre: 'PC-02', disponible: true),
        Equipo(nombre: 'PC-03', disponible: true),
        Equipo(nombre: 'PC-04', disponible: true),
      ],
    };
    _salonesDropdown['SALÓN 101'] = ['PC-01', 'PC-02', 'PC-03', 'PC-04', 'PC-05'];
    _salonesDropdown['SALÓN 102'] = ['PC-01', 'PC-02', 'PC-03'];
    _salonesDropdown['SALÓN 103'] = ['PC-01', 'PC-02', 'PC-03', 'PC-04'];

    try {
      _usuarios = await _fs.getUsuarios();
    } catch (_) {
      _initDataLocalUsuarios();
    }
    try {
      _recursos = await _fs.getRecursos();
      if (_recursos.isEmpty) {
        await _sembrarSiVacio();
      } else {
        for (final r in _recursos) {
          if (r.disponible != r.total) {
            r.disponible = r.total;
            await _fs.setRecurso(r);
          }
        }
      }
    } catch (_) {
      _initDataLocalRecursos();
    }
    try {
      _solicitudes = await _fs.getSolicitudes();
    } catch (_) {}
    try {
      _prestamos = await _fs.getPrestamos();
    } catch (_) {}
    try {
      _notificaciones = await _fs.getNotificaciones();
    } catch (_) {}
    try {
      if (_usuarios.isEmpty) {
        await _sembrarSiVacio();
      }
    } catch (_) {}
    try {
      await _asegurarAdminExiste().timeout(const Duration(seconds: 5));
    } catch (_) {}
    await _sincronizarComputadores();
    _cargando = false;
    notifyListeners();
    await _generarAlertasPrestamos();
    await _verificarSesionGuardada();
  }

  void _initDataLocalUsuarios() {
    _usuarios = [
      Usuario(nombre: 'Administrador', correo: 'admin@uts.com', documento: '0000000000',
          programa: 'ADMINISTRACIÓN', activo: true, esAdmin: true),
    ];
  }

  void _initDataLocalRecursos() {
    _recursos = [
      Recurso(nombre: 'COMPUTADOR', icono: 'computer', total: 15, disponible: 15,
          categoria: CategoriaRecurso.equipos),
      Recurso(nombre: 'VIDEO BEAM', icono: 'videocam', total: 6, disponible: 6,
          categoria: CategoriaRecurso.equipos, codigoBarras: 'VB-001',
          accesoriosIncluidos: ['CABLE HDMI', 'CONTROL REMOTO', 'MALETA']),
      Recurso(nombre: 'PARLANTES', icono: 'speaker', total: 6, disponible: 6,
          categoria: CategoriaRecurso.equipos, codigoBarras: 'PAR-001',
          accesoriosIncluidos: ['CABLE RCA', 'MICRÓFONO INALÁMBRICO']),
      Recurso(nombre: 'CABLE HDMI', icono: 'cable', total: 8, disponible: 8,
          categoria: CategoriaRecurso.cables, codigoBarras: 'HDMI-001'),
      Recurso(nombre: 'CABLE RCA', icono: 'settings_input_composite', total: 6, disponible: 6,
          categoria: CategoriaRecurso.cables),
      Recurso(nombre: 'CABLE USB', icono: 'usb', total: 5, disponible: 5,
          categoria: CategoriaRecurso.cables),
      Recurso(nombre: 'EXTENSIÓN', icono: 'electrical_services', total: 8, disponible: 8,
          categoria: CategoriaRecurso.otros),
    ];
  }

  Future<void> _sembrarSiVacio() async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: 'admin@uts.com', password: 'admin123');
    } catch (_) {}
    if (!_usuarios.any((u) => u.correo == 'admin@uts.com')) {
      _usuarios.add(Usuario(nombre: 'Administrador', correo: 'admin@uts.com',
          documento: '0000000000', programa: 'ADMINISTRACIÓN', activo: true, esAdmin: true));
    }
    final nombresExistentes = _recursos.map((r) => r.nombre).toSet();
    for (final r in [
      Recurso(nombre: 'COMPUTADOR', icono: 'computer', total: 15, disponible: 15,
          categoria: CategoriaRecurso.equipos),
      Recurso(nombre: 'VIDEO BEAM', icono: 'videocam', total: 6, disponible: 6,
          categoria: CategoriaRecurso.equipos, codigoBarras: 'VB-001',
          accesoriosIncluidos: ['CABLE HDMI', 'CONTROL REMOTO', 'MALETA']),
      Recurso(nombre: 'PARLANTES', icono: 'speaker', total: 6, disponible: 6,
          categoria: CategoriaRecurso.equipos, codigoBarras: 'PAR-001',
          accesoriosIncluidos: ['CABLE RCA', 'MICRÓFONO INALÁMBRICO']),
      Recurso(nombre: 'CABLE HDMI', icono: 'cable', total: 8, disponible: 8,
          categoria: CategoriaRecurso.cables, codigoBarras: 'HDMI-001'),
      Recurso(nombre: 'CABLE RCA', icono: 'settings_input_composite', total: 6, disponible: 6,
          categoria: CategoriaRecurso.cables),
      Recurso(nombre: 'CABLE USB', icono: 'usb', total: 5, disponible: 5,
          categoria: CategoriaRecurso.cables),
      Recurso(nombre: 'EXTENSIÓN', icono: 'electrical_services', total: 8, disponible: 8,
          categoria: CategoriaRecurso.otros),
    ]) {
      if (!nombresExistentes.contains(r.nombre)) {
        _recursos.add(r);
      }
    }
    for (final u in _usuarios) { await _fs.setUsuario(u); }
    for (final r in _recursos) { await _fs.setRecurso(r); }
  }

  Future<void> refrescarDatos() async {
    try {
      _usuarios = await _fs.getUsuarios();
    } catch (_) {
      _initDataLocalUsuarios();
    }
    try {
      _recursos = await _fs.getRecursos();
    } catch (_) {
      _initDataLocalRecursos();
    }
    try {
      _solicitudes = await _fs.getSolicitudes();
    } catch (_) {}
    try {
      _prestamos = await _fs.getPrestamos();
    } catch (_) {}
    try {
      _notificaciones = await _fs.getNotificaciones();
    } catch (_) {}
    await _asegurarAdminExiste();
    await _generarAlertasPrestamos();
    await _sincronizarComputadores();
    notifyListeners();
  }

  Future<void> _asegurarAdminExiste() async {
    try {
      if (!_usuarios.any((u) => u.correo == 'admin@uts.com')) {
        final admin = Usuario(nombre: 'Administrador', correo: 'admin@uts.com',
            documento: '0000000000', programa: 'ADMINISTRACIÓN', activo: true, esAdmin: true);
        _usuarios.add(admin);
        await _fs.setUsuario(admin);
      }
      try {
        await _auth.createUserWithEmailAndPassword(
            email: 'admin@uts.com', password: 'admin123');
      } catch (_) {} // already exists
    } catch (_) {} // skip if offline
  }

  // ─── RECURSOS ─────────────────────────────────────────────
  Future<void> agregarRecurso(Recurso r) async {
    _recursos.add(r);
    await _fs.setRecurso(r);
    notifyListeners();
  }

  Future<void> editarRecurso(int index, Recurso r) async {
    if (index >= 0 && index < _recursos.length) {
      _recursos[index] = r;
      await _fs.setRecurso(r);
      notifyListeners();
    }
  }

  Future<void> eliminarRecurso(int index) async {
    if (index >= 0 && index < _recursos.length) {
      final r = _recursos.removeAt(index);
      await _fs.deleteRecurso(r.nombre);
      notifyListeners();
    }
  }

  Recurso? recursoPorCodigo(String codigo) {
    try {
      return _recursos.firstWhere(
          (r) => r.codigoBarras?.toUpperCase() == codigo.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  Prestamo? prestamoActivoPorRecurso(String recursoNombre) {
    try {
      return _prestamos.firstWhere((p) =>
          p.recursoNombre == recursoNombre &&
          p.estado == EstadoPrestamo.activo);
    } catch (_) {
      return null;
    }
  }

  Future<void> devolverPrestamo(Prestamo prestamo) async {
    final idx = _prestamos.indexOf(prestamo);
    if (idx == -1) return;
    if (_prestamos[idx].estado == EstadoPrestamo.devuelto) return;
    final yaVencido = _prestamos[idx].estado == EstadoPrestamo.vencido;
    _prestamos[idx].estado = EstadoPrestamo.devuelto;
    await _fs.updatePrestamoEstado(prestamo.id, 'devuelto');
    if (!yaVencido) {
      final recurso = _recursos.where((r) =>
          r.nombre == prestamo.recursoNombre).firstOrNull;
      if (recurso != null) {
        recurso.disponible++;
        await _fs.actualizarDisponibilidad(recurso.nombre, recurso.disponible);
      }
    }
    notifyListeners();
    await actualizarAlertas();
  }

  Future<void> _sincronizarComputadores() async {
    final totalPCs = _salones.values.fold(0, (sum, equipos) => sum + equipos.length);
    final disponiblesPCs = _salones.values.fold(0, (sum, equipos) => sum + equipos.where((e) => e.disponible).length);
    final compu = _recursos.where((r) => r.nombre == 'COMPUTADOR').firstOrNull;
    if (compu != null) {
      compu.total = totalPCs;
      compu.disponible = disponiblesPCs;
      try {
        await _fs.setRecurso(compu);
      } catch (_) {}
    }
  }

  // ─── SALONES ──────────────────────────────────────────────
  Future<void> agregarSalon(String nombre) async {
    _salones[nombre] = [];
    _salonesDropdown[nombre] = [];
    await _sincronizarComputadores();
    notifyListeners();
  }

  void editarSalon(String nombreOriginal, String nuevoNombre) {
    if (nombreOriginal == nuevoNombre) return;
    _salones[nuevoNombre] = _salones.remove(nombreOriginal) ?? [];
    _salonesDropdown[nuevoNombre] = _salonesDropdown.remove(nombreOriginal) ?? [];
    notifyListeners();
  }

  Future<void> eliminarSalon(String nombre) async {
    _salones.remove(nombre);
    _salonesDropdown.remove(nombre);
    await _sincronizarComputadores();
    notifyListeners();
  }

  Future<void> agregarEquipo(String salon, String equipo) async {
    _salones[salon]?.add(Equipo(nombre: equipo, disponible: true));
    _salonesDropdown[salon]?.add(equipo);
    await _sincronizarComputadores();
    notifyListeners();
  }

  Future<void> eliminarEquipo(String salon, String equipo) async {
    _salones[salon]?.removeWhere((e) => e.nombre == equipo);
    _salonesDropdown[salon]?.remove(equipo);
    await _sincronizarComputadores();
    notifyListeners();
  }

  // ─── USUARIOS ─────────────────────────────────────────────
  Future<void> toggleUsuarioActivo(int index) async {
    if (index >= 0 && index < _usuarios.length) {
      _usuarios[index].activo = !_usuarios[index].activo;
      await _fs.setUsuario(_usuarios[index]);
      notifyListeners();
    }
  }

  // ─── SOLICITUDES ──────────────────────────────────────────
  Future<void> agregarSolicitud(Solicitud s) async {
    _solicitudes.add(s);
    await _fs.setSolicitud(s);
    final notif = Notificacion(
      tipo: TipoNotificacion.solicitud,
      titulo: 'NUEVA SOLICITUD',
      mensaje: '${_usuarioActual?.nombre ?? 'Usuario'} solicitó ${s.recursoNombre}',
      hora: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
      solicitudId: s.id,
    );
    _notificaciones.add(notif);
    await _fs.setNotificacion(notif);
    NotificacionService().mostrarNotificacion(
      titulo: 'NUEVA SOLICITUD',
      cuerpo: '${_usuarioActual?.nombre ?? 'Usuario'} solicitó ${s.recursoNombre}',
    );
    notifyListeners();
  }

  Future<void> aprobarSolicitud(int index) async {
    if (index >= 0 && index < _solicitudes.length) {
      _solicitudes[index].estado = EstadoSolicitud.aprobada;
      await _fs.updateSolicitudEstado(_solicitudes[index].id, 'aprobada');
      final s = _solicitudes[index];
      final prestamo = Prestamo(
        usuarioNombre: s.usuarioNombre,
        recursoNombre: s.recursoNombre,
        recursoIcono: s.recursoIcono,
        salon: s.salon,
        equipo: s.equipo,
        accesorios: List.from(s.accesorios),
        fechaPrestamo: s.fechaPrestamo,
        fechaDevolucion: s.fechaDevolucion,
        estado: EstadoPrestamo.activo,
      );
      _prestamos.add(prestamo);
      await _fs.setPrestamo(prestamo);
      final recurso = _recursos.where((r) =>
          r.nombre == s.recursoNombre).firstOrNull;
      if (recurso != null && recurso.disponible > 0) {
        recurso.disponible--;
        await _fs.actualizarDisponibilidad(recurso.nombre, recurso.disponible);
      }
      await _marcarNotificacionSolicitudResuelta(s.id);
      final correoUser = _usuarios.where((u) => u.nombre == s.usuarioNombre).firstOrNull?.correo;
      final notifUser = Notificacion(
        tipo: TipoNotificacion.aprobado,
        titulo: 'PRÉSTAMO APROBADO',
        mensaje: 'Tu solicitud de ${s.recursoNombre} fue aprobada.',
        hora: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        usuarioCorreo: correoUser,
      );
      _notificaciones.add(notifUser);
      await _fs.setNotificacion(notifUser);
      NotificacionService().mostrarNotificacion(
        titulo: 'PRÉSTAMO APROBADO',
        cuerpo: '${s.usuarioNombre} — ${s.recursoNombre} aprobado',
      );
      notifyListeners();
      await actualizarAlertas();
    }
  }

  Future<void> rechazarSolicitud(int index) async {
    if (index >= 0 && index < _solicitudes.length) {
      _solicitudes[index].estado = EstadoSolicitud.rechazada;
      final solicitudId = _solicitudes[index].id;
      await _fs.updateSolicitudEstado(solicitudId, 'rechazada');
      await _marcarNotificacionSolicitudResuelta(solicitudId);
      final s = _solicitudes[index];
      final correoUser = _usuarios.where((u) => u.nombre == s.usuarioNombre).firstOrNull?.correo;
      final notifUser = Notificacion(
        tipo: TipoNotificacion.aprobado,
        titulo: 'SOLICITUD RECHAZADA',
        mensaje: 'Tu solicitud de ${s.recursoNombre} fue rechazada.',
        hora: '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        usuarioCorreo: correoUser,
      );
      _notificaciones.add(notifUser);
      await _fs.setNotificacion(notifUser);
      NotificacionService().mostrarNotificacion(
        titulo: 'SOLICITUD RECHAZADA',
        cuerpo: '${s.usuarioNombre} — ${s.recursoNombre} rechazado',
      );
      notifyListeners();
    }
  }

  Future<void> aprobarSolicitudPorId(String solicitudId) async {
    final index = _solicitudes.indexWhere((s) => s.id == solicitudId);
    if (index >= 0) await aprobarSolicitud(index);
  }

  Future<void> rechazarSolicitudPorId(String solicitudId) async {
    final index = _solicitudes.indexWhere((s) => s.id == solicitudId);
    if (index >= 0) await rechazarSolicitud(index);
  }

  Future<void> _marcarNotificacionSolicitudResuelta(String solicitudId) async {
    for (int i = 0; i < _notificaciones.length; i++) {
      if (_notificaciones[i].solicitudId == solicitudId && !_notificaciones[i].leida) {
        _notificaciones[i].leida = true;
        await _fs.marcarNotificacionLeida(_notificaciones[i].id);
        break;
      }
    }
  }

  // ─── NOTIFICACIONES ───────────────────────────────────────
  Future<void> marcarNotificacionLeida(int index) async {
    if (index >= 0 && index < _notificaciones.length) {
      _notificaciones[index].leida = true;
      await _fs.marcarNotificacionLeida(_notificaciones[index].id);
      notifyListeners();
    }
  }

  Future<void> eliminarNotificacion(int index) async {
    if (index >= 0 && index < _notificaciones.length) {
      final n = _notificaciones.removeAt(index);
      await _fs.deleteNotificacion(n.id);
      notifyListeners();
    }
  }

  // ─── ALERTAS ──────────────────────────────────────────────
  Future<void> _generarAlertasPrestamos() async {
    final now = DateTime.now();
    final enDosHoras = now.add(const Duration(hours: 2));

    for (final p in _prestamos) {
      if (p.estado != EstadoPrestamo.activo) continue;
      final key = '${p.recursoNombre}_${p.usuarioNombre}';
      if (p.fechaDevolucion.isBefore(now) && !_prestamosConAlerta.contains(key)) {
        p.estado = EstadoPrestamo.vencido;
        await _fs.updatePrestamoEstado(p.id, 'vencido');
        final recurso = _recursos.where((r) =>
            r.nombre == p.recursoNombre).firstOrNull;
        if (recurso != null) {
          recurso.disponible++;
          await _fs.actualizarDisponibilidad(recurso.nombre, recurso.disponible);
        }
        final correoUser = _usuarios.where((u) => u.nombre == p.usuarioNombre).firstOrNull?.correo;
        final not = Notificacion(
          tipo: TipoNotificacion.vencido,
          titulo: 'Préstamo vencido',
          mensaje: '${p.recursoNombre} - ${p.usuarioNombre} venció el ${p.fechaDevolucionStr}.',
          hora: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          usuarioCorreo: correoUser,
        );
        _notificaciones.add(not);
        await _fs.setNotificacion(not);
        NotificacionService().mostrarNotificacion(
          titulo: 'Préstamo vencido',
          cuerpo: '${p.recursoNombre} - ${p.usuarioNombre} venció el ${p.fechaDevolucionStr}.',
        );
        _prestamosConAlerta.add(key);
      } else if (p.fechaDevolucion.isBefore(enDosHoras) &&
          p.fechaDevolucion.isAfter(now) &&
          !_prestamosConAlerta.contains(key)) {
        final correoUser = _usuarios.where((u) => u.nombre == p.usuarioNombre).firstOrNull?.correo;
        final not = Notificacion(
          tipo: TipoNotificacion.recordatorio,
          titulo: 'Devolución próxima',
          mensaje: '${p.recursoNombre} - ${p.usuarioNombre} debe devolverse antes de las '
              '${p.fechaDevolucion.hour.toString().padLeft(2, '0')}:${p.fechaDevolucion.minute.toString().padLeft(2, '0')}.',
          hora: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          usuarioCorreo: correoUser,
        );
        _notificaciones.add(not);
        await _fs.setNotificacion(not);
        NotificacionService().mostrarNotificacion(
          titulo: 'Devolución próxima',
          cuerpo: '${p.recursoNombre} - ${p.usuarioNombre} debe devolverse antes de las '
              '${p.fechaDevolucion.hour.toString().padLeft(2, '0')}:${p.fechaDevolucion.minute.toString().padLeft(2, '0')}.',
        );
        _prestamosConAlerta.add(key);
      }
    }
  }

  Future<void> actualizarAlertas() async {
    await _generarAlertasPrestamos();
    notifyListeners();
  }

  Map<String, dynamic> recursoMasPrestado() {
    final Map<String, int> conteo = {};
    final Map<String, String> iconos = {};
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
    if (conteo.isEmpty) {
      return {'nombre': 'N/A', 'cantidad': 0, 'icono': 'help_outline', 'porcentaje': 0.0};
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
      'icono': _recursos
          .where((r) => r.nombre.trim().toUpperCase() == p.recursoNombre.trim().toUpperCase())
          .firstOrNull?.icono ?? 'inventory_2',
    }).toList();
  }
}
