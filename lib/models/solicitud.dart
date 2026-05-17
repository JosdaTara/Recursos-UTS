import 'package:flutter/material.dart';

// Estados de una solicitud de préstamo
enum EstadoSolicitud { pendiente, aprobada, rechazada }

// Modelo que representa una solicitud de préstamo hecha por un usuario
class Solicitud {
  String usuarioNombre;     // Nombre del usuario que solicita
  String documento;         // Documento de identidad del solicitante
  String programa;          // Programa académico del solicitante
  String recursoNombre;     // Nombre del recurso que se solicita
  IconData recursoIcono;    // Icono del recurso para mostrar en la UI
  List<String> accesorios;  // Accesorios adicionales solicitados
  String? salon;            // Salón donde se usará (opcional)
  String? equipo;           // Equipo específico del salón (opcional)
  DateTime fechaPrestamo;       // Fecha y hora de inicio deseada
  DateTime fechaDevolucion;     // Fecha y hora de devolución deseada
  DateTime fechaSolicitud;      // Momento exacto en que se creó la solicitud
  EstadoSolicitud estado;       // Estado: pendiente, aprobada o rechazada

  Solicitud({
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
    this.estado = EstadoSolicitud.pendiente, // Al crearse, la solicitud está pendiente
  });

  // Retorna la fecha de préstamo como texto en formato dd/mm/aaaa
  String get fechaPrestamoStr =>
      '${fechaPrestamo.day.toString().padLeft(2, '0')}/${fechaPrestamo.month.toString().padLeft(2, '0')}/${fechaPrestamo.year}';

  // Retorna la fecha de devolución como texto en formato dd/mm/aaaa
  String get fechaDevolucionStr =>
      '${fechaDevolucion.day.toString().padLeft(2, '0')}/${fechaDevolucion.month.toString().padLeft(2, '0')}/${fechaDevolucion.year}';

  // Retorna la fecha de solicitud en formato relativo:
  // "Hoy, 14:30" si fue hoy, "Ayer, 10:00" si fue ayer, o "dd/mm/aaaa" si fue antes
  String get fechaSolicitudStr {
    final diff = DateTime.now().difference(fechaSolicitud);
    if (diff.inDays == 0) {
      return 'Hoy, ${fechaSolicitud.hour.toString().padLeft(2, '0')}:${fechaSolicitud.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ayer, ${fechaSolicitud.hour.toString().padLeft(2, '0')}:${fechaSolicitud.minute.toString().padLeft(2, '0')}';
    }
    return '${fechaSolicitud.day.toString().padLeft(2, '0')}/${fechaSolicitud.month.toString().padLeft(2, '0')}/${fechaSolicitud.year}';
  }
}
