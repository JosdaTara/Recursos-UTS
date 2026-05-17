// Widget que envuelve cada pantalla con el fondo institucional.
// Usa un Scaffold con imagen de fondo semitransparente + gradiente oscuro superpuesto.
import 'package:flutter/material.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';

class BackgroundScaffold extends StatelessWidget {
  final Widget child;            // Contenido de la pantalla que va encima del fondo
  final Color backgroundColor;   // Color base del fondo (por defecto primaryLight)

  const BackgroundScaffold({
    super.key,
    required this.child,
    this.backgroundColor = AppColors.bgDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Imagen de fondo con opacidad reducida
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset('assets/background.png', fit: BoxFit.cover),
            ),
          ),
          // Degradado oscuro encima de la imagen para mejorar legibilidad
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.gradientOverlay),
            ),
          ),
          // Contenido de la pantalla respetando áreas seguras (notch, etc.)
          SafeArea(child: child),
        ],
      ),
    );
  }
}
