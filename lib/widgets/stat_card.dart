// Tarjeta de estadística con un valor grande y una etiqueta descriptiva.
// Se usa en el panel de administración (ej: "15 PRÉSTAMOS ACTIVOS").
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;   // Texto descriptivo (ej: "PRÉSTAMOS\nACTIVOS")
  final String valor;   // Valor numérico (ej: "15")
  final Color color;    // Color del número y borde

  const StatCard({
    super.key,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
