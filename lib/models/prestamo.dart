import 'package:flutter/material.dart';

// Estados por los que puede pasar un préstamo
enum EstadoPrestamo { activo, devuelto, vencido }

// Modelo que representa un préstamo ya aprobado y en curso/finalizado
class Prestamo {
  String usuarioNombre;         // Nombre del usuario que tomó prestado el recurso
  String recursoNombre;         // Nombre del recurso prestado
  IconData recursoIcono;        // Icono del recurso para mostrar en la UI
  String? salon;                // Salón donde se usará el recurso (opcional)
  String? equipo;               // Equipo específico del salón (opcional, ej: PC-01)
  List<String> accesorios;      // Accesorios solicitados junto con el recurso
  DateTime fechaPrestamo;       // Fecha y hora de inicio del préstamo
  DateTime fechaDevolucion;     // Fecha y hora límite para devolver
  EstadoPrestamo estado;        // Estado actual del préstamo

  Prestamo({
    required this.usuarioNombre,
    required this.recursoNombre,
    required this.recursoIcono,
    this.salon,
    this.equipo,
    this.accesorios = const [],
    required this.fechaPrestamo,
    required this.fechaDevolucion,
    this.estado = EstadoPrestamo.activo, // Al crearse, el préstamo está activo
  });

  // Retorna la fecha de préstamo como texto en formato dd/mm/aaaa
  String get fechaPrestamoStr =>
      '${fechaPrestamo.day.toString().padLeft(2, '0')}/${fechaPrestamo.month.toString().padLeft(2, '0')}/${fechaPrestamo.year}';

  // Retorna la fecha de devolución como texto en formato dd/mm/aaaa
  String get fechaDevolucionStr =>
      '${fechaDevolucion.day.toString().padLeft(2, '0')}/${fechaDevolucion.month.toString().padLeft(2, '0')}/${fechaDevolucion.year}';
}
