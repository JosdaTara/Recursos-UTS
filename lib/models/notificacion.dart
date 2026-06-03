import 'package:cloud_firestore/cloud_firestore.dart';

// Enum que clasifica el tipo de notificación
enum TipoNotificacion {
  aprobado,    // Préstamo aprobado por el administrador
  recordatorio, // Recordatorio de devolución próxima a vencer
  vencido,      // Préstamo cuya fecha de devolución ya expiró
  solicitud,   // Nueva solicitud de préstamo (admin puede aceptar/rechazar)
}

class Notificacion {
  String id;
  TipoNotificacion tipo;
  String titulo;
  String mensaje;
  String hora;
  DateTime fecha;
  bool leida;
  String? solicitudId;
  String? usuarioCorreo;

  Notificacion({
    String? id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.hora,
    DateTime? fecha,
    this.leida = false,
    this.solicitudId,
    this.usuarioCorreo,
  }) : id = id ?? 'not_${DateTime.now().millisecondsSinceEpoch}',
       fecha = fecha ?? DateTime.now();

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'tipo': tipo.name,
    'titulo': titulo,
    'mensaje': mensaje,
    'hora': hora,
    'fecha': fecha.toIso8601String(),
    'leida': leida,
    if (solicitudId != null) 'solicitudId': solicitudId,
    if (usuarioCorreo != null) 'usuarioCorreo': usuarioCorreo,
  };

  factory Notificacion.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Notificacion(
      id: d['id'] as String? ?? doc.id,
      tipo: TipoNotificacion.values.firstWhere(
          (t) => t.name == d['tipo'],
          orElse: () => TipoNotificacion.aprobado),
      titulo: d['titulo'] as String,
      mensaje: d['mensaje'] as String,
      hora: d['hora'] as String,
      fecha: d['fecha'] != null ? DateTime.parse(d['fecha'] as String) : null,
      leida: d['leida'] as bool? ?? false,
      solicitudId: d['solicitudId'] as String?,
      usuarioCorreo: d['usuarioCorreo'] as String?,
    );
  }
}
