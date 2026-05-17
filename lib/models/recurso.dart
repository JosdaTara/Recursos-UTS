import 'package:flutter/material.dart';

// Categorías para clasificar y filtrar los recursos
enum CategoriaRecurso { todos, equipos, cables, otros }

// Modelo que representa un recurso prestable (computador, video beam, cable, etc.)
class Recurso {
  String nombre;                        // Nombre del recurso (ej: VIDEO BEAM)
  IconData icono;                       // Icono de Material Design para mostrar en la UI
  int total;                            // Cantidad total que existe del recurso
  int disponible;                       // Cantidad disponible actualmente para préstamo
  CategoriaRecurso categoria;           // Categoría para agrupar y filtrar
  String? codigoBarras;                 // Código de barras único (opcional, ej: VB-001)
  List<String> accesoriosIncluidos;     // Lista de accesorios que vienen con el recurso

  Recurso({
    required this.nombre,
    required this.icono,
    required this.total,
    required this.disponible,
    this.categoria = CategoriaRecurso.otros,
    this.codigoBarras,
    this.accesoriosIncluidos = const [],
  });

  // Retorna el porcentaje de disponibilidad (0.0 a 1.0)
  double get porcentajeDisponible => total > 0 ? disponible / total : 0;
}
