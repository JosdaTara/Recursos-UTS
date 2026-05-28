import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_recursos_uts/models/usuario.dart';
import 'package:flutter_recursos_uts/models/recurso.dart';
import 'package:flutter_recursos_uts/models/solicitud.dart';
import 'package:flutter_recursos_uts/models/prestamo.dart';
import 'package:flutter_recursos_uts/models/notificacion.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── USUARIOS ──────────────────────────────────────────────

  Future<List<Usuario>> getUsuarios() async {
    final snap = await _db.collection('usuarios').get();
    return snap.docs.map((d) => Usuario.fromFirestore(d)).toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> usuariosStream() {
    return _db.collection('usuarios').snapshots();
  }

  Future<void> setUsuario(Usuario u) async {
    await _db.collection('usuarios').doc(u.correo).set(u.toFirestore());
  }

  Future<void> deleteUsuario(String correo) async {
    await _db.collection('usuarios').doc(correo).delete();
  }

  Future<Usuario?> getUsuarioPorCorreo(String correo) async {
    final doc = await _db.collection('usuarios').doc(correo).get();
    if (!doc.exists) return null;
    return Usuario.fromFirestore(doc);
  }

  // ─── RECURSOS ──────────────────────────────────────────────

  Future<List<Recurso>> getRecursos() async {
    final snap = await _db.collection('recursos').get();
    return snap.docs.map((d) => Recurso.fromFirestore(d)).toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> recursosStream() {
    return _db.collection('recursos').snapshots();
  }

  Future<void> setRecurso(Recurso r) async {
    await _db.collection('recursos').doc(r.nombre).set(r.toFirestore());
  }

  Future<void> deleteRecurso(String nombre) async {
    await _db.collection('recursos').doc(nombre).delete();
  }

  Future<void> actualizarDisponibilidad(String nombre, int disponible) async {
    await _db.collection('recursos').doc(nombre).update({'disponible': disponible});
  }

  // ─── SOLICITUDES ───────────────────────────────────────────

  Future<List<Solicitud>> getSolicitudes() async {
    final snap = await _db.collection('solicitudes').orderBy('fechaSolicitud', descending: true).get();
    return snap.docs.map((d) => Solicitud.fromFirestore(d)).toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> solicitudesStream() {
    return _db.collection('solicitudes').orderBy('fechaSolicitud', descending: true).snapshots();
  }

  Future<void> setSolicitud(Solicitud s) async {
    await _db.collection('solicitudes').doc(s.id).set(s.toFirestore());
  }

  Future<void> updateSolicitudEstado(String id, String estado) async {
    await _db.collection('solicitudes').doc(id).update({'estado': estado});
  }

  // ─── PRESTAMOS ─────────────────────────────────────────────

  Future<List<Prestamo>> getPrestamos() async {
    final snap = await _db.collection('prestamos').orderBy('fechaPrestamo', descending: true).get();
    return snap.docs.map((d) => Prestamo.fromFirestore(d)).toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> prestamosStream() {
    return _db.collection('prestamos').orderBy('fechaPrestamo', descending: true).snapshots();
  }

  Future<void> setPrestamo(Prestamo p) async {
    await _db.collection('prestamos').doc(p.id).set(p.toFirestore());
  }

  Future<void> updatePrestamoEstado(String id, String estado) async {
    await _db.collection('prestamos').doc(id).update({'estado': estado});
  }

  // ─── NOTIFICACIONES ────────────────────────────────────────

  Future<List<Notificacion>> getNotificaciones() async {
    final snap = await _db.collection('notificaciones').orderBy('fecha', descending: true).get();
    return snap.docs.map((d) => Notificacion.fromFirestore(d)).toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> notificacionesStream() {
    return _db.collection('notificaciones').orderBy('fecha', descending: true).snapshots();
  }

  Future<void> setNotificacion(Notificacion n) async {
    await _db.collection('notificaciones').doc(n.id).set(n.toFirestore());
  }

  Future<void> marcarNotificacionLeida(String id) async {
    await _db.collection('notificaciones').doc(id).update({'leida': true});
  }

  Future<void> marcarTodasLeidas() async {
    final snap = await _db.collection('notificaciones').where('leida', isEqualTo: false).get();
    for (final doc in snap.docs) {
      await doc.reference.update({'leida': true});
    }
  }
}
