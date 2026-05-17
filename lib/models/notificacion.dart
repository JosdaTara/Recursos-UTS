// Enum que clasifica el tipo de notificación
enum TipoNotificacion {
  aprobado,    // Préstamo aprobado por el administrador
  recordatorio, // Recordatorio de devolución próxima a vencer
  vencido,      // Préstamo cuya fecha de devolución ya expiró
}

// Modelo que representa una notificación dentro de la app
class Notificacion {
  TipoNotificacion tipo;  // Clasificación de la notificación
  String titulo;          // Título corto (ej: "Préstamo vencido")
  String mensaje;         // Mensaje descriptivo con detalles
  String hora;            // Texto con la hora relativa (ej: "Hoy, 3:00 PM")
  bool leida;             // false = no leída (se muestra resaltada)

  Notificacion({
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.hora,
    this.leida = false, // Por defecto la notificación no ha sido leída
  });
}
