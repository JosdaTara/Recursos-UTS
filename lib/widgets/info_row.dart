// Fila de información con icono, etiqueta a la izquierda y valor alineado a la derecha.
// Se usa en los detalles de préstamos/solicitudes (ej: icono usuario + "Nombre: Pedro Ruiz").
import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icono;         // Icono ilustrativo (ej: Icons.person)
  final String label;          // Nombre del campo (ej: "Usuario")
  final String valor;          // Valor del campo (ej: "Pedro Ruiz")
  final bool multilinea;       // true si el valor puede ocupar varias líneas

  const InfoRow({
    super.key,
    required this.icono,
    required this.label,
    required this.valor,
    this.multilinea = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
            multilinea ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icono, color: Colors.white54, size: 18),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
