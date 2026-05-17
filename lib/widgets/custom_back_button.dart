// Botón de retroceso circular semitransparente.
// Se usa en la mayoría de pantallas para volver a la pantalla anterior.
import 'package:flutter/material.dart';

class CustomBackButton extends StatelessWidget {
  // Callback opcional. Si no se provee, hace Navigator.pop() automáticamente.
  final VoidCallback? onTap;

  const CustomBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.25),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
      ),
    );
  }
}
