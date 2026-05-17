// Modelo que representa un equipo de cómputo dentro de un salón
class Equipo {
  String nombre;   // Identificador del equipo (ej: PC-01)
  bool disponible; // true = disponible para préstamo, false = ya prestado

  Equipo({
    required this.nombre,
    this.disponible = true, // Por defecto el equipo se crea disponible
  });
}
