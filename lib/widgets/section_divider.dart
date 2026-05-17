// Divisor de secciones con texto centrado entre dos líneas.
// Útil para separar visualmente bloques de contenido en una pantalla.
import 'package:flutter/material.dart';

class SectionDivider extends StatelessWidget {
  final String titulo;  // Texto que aparece entre las líneas divisorias

  const SectionDivider({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            titulo,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
      ],
    );
  }
}
