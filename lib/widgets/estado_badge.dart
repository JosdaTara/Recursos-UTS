// Etiqueta tipo "badge" coloreada para mostrar el estado de un préstamo/solicitud.
import 'package:flutter/material.dart';

class EstadoBadge extends StatelessWidget {
  final String texto;       // Texto del badge (ej: "ACTIVO", "DEVUELTO")
  final Color color;        // Color de fondo y borde (ej: green para devuelto)
  final double fontSize;    // Tamaño de fuente (default 11)

  const EstadoBadge({
    super.key,
    required this.texto,
    required this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
