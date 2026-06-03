import 'package:cloud_firestore/cloud_firestore.dart';

// Estados de una solicitud de préstamo
enum EstadoSolicitud { pendiente, aprobada, rechazada }

class Solicitud {
  String id;
  String usuarioNombre;
  String documento;
  String programa;
  String recursoNombre;
  String recursoIcono;
  List<String> accesorios;
  String? salon;
  String? equipo;
  DateTime fechaPrestamo;
  DateTime fechaDevolucion;
  DateTime fechaSolicitud;
  EstadoSolicitud estado;

  Solicitud({
    String? id,
    required this.usuarioNombre,
    required this.documento,
    required this.programa,
    required this.recursoNombre,
    required this.recursoIcono,
    this.accesorios = const [],
    this.salon,
    this.equipo,
    required this.fechaPrestamo,
    required this.fechaDevolucion,
    required this.fechaSolicitud,
    this.estado = EstadoSolicitud.pendiente,
  }) : id = id ?? 'sol_${fechaSolicitud.millisecondsSinceEpoch}';

  String get fechaPrestamoStr =>
      '${fechaPrestamo.day.toString().padLeft(2, '0')}/${fechaPrestamo.month.toString().padLeft(2, '0')}/${fechaPrestamo.year}';

  String get fechaDevolucionStr =>
      '${fechaDevolucion.day.toString().padLeft(2, '0')}/${fechaDevolucion.month.toString().padLeft(2, '0')}/${fechaDevolucion.year}';

  String get fechaSolicitudStr {
    final diff = DateTime.now().difference(fechaSolicitud);
    if (diff.inDays == 0) {
      return 'Hoy, ${fechaSolicitud.hour.toString().padLeft(2, '0')}:${fechaSolicitud.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer, ${fechaSolicitud.hour.toString().padLeft(2, '0')}:${fechaSolicitud.minute.toString().padLeft(2, '0')}';
    }
    return '${fechaSolicitud.day.toString().padLeft(2, '0')}/${fechaSolicitud.month.toString().padLeft(2, '0')}/${fechaSolicitud.year}';
  }

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'usuarioNombre': usuarioNombre,
    'documento': documento,
    'programa': programa,
    'recursoNombre': recursoNombre,
    'recursoIcono': recursoIcono,
    'accesorios': accesorios,
    'salon': salon,
    'equipo': equipo,
    'fechaPrestamo': fechaPrestamo.toIso8601String(),
    'fechaDevolucion': fechaDevolucion.toIso8601String(),
    'fechaSolicitud': fechaSolicitud.toIso8601String(),
    'estado': estado.name,
  };

  factory Solicitud.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Solicitud(
      id: d['id'] as String? ?? doc.id,
      usuarioNombre: d['usuarioNombre'] as String,
      documento: d['documento'] as String,
      programa: d['programa'] as String,
      recursoNombre: d['recursoNombre'] as String,
      recursoIcono: d['recursoIcono'] is String && (d['recursoIcono'] as String).isNotEmpty
          ? d['recursoIcono'] as String : 'inventory_2',
      accesorios: (d['accesorios'] as List).cast<String>(),
      salon: d['salon'] as String?,
      equipo: d['equipo'] as String?,
      fechaPrestamo: DateTime.parse(d['fechaPrestamo'] as String),
      fechaDevolucion: DateTime.parse(d['fechaDevolucion'] as String),
      fechaSolicitud: DateTime.parse(d['fechaSolicitud'] as String),
      estado: EstadoSolicitud.values.firstWhere(
          (e) => e.name == d['estado'],
          orElse: () => EstadoSolicitud.pendiente),
    );
  }
}
