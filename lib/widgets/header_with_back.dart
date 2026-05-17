// Encabezado de pantalla con botón de retroceso a la izquierda y un widget opcional a la derecha.
import 'package:flutter/material.dart';
import 'package:flutter_recursos_uts/widgets/custom_back_button.dart';

class HeaderWithBack extends StatelessWidget {
  final String titulo;        // Texto del título
  final Widget? trailing;     // Widget opcional a la derecha (ej: icono de acción)
  final VoidCallback? onBack; // Callback personalizado para el botón de retroceso

  const HeaderWithBack({
    super.key,
    required this.titulo,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          CustomBackButton(onTap: onBack),
          const SizedBox(width: 12),
          Text(
            titulo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}
