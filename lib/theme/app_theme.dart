import 'package:flutter/material.dart';

// --- Paleta de colores global de la aplicación ---
class AppColors {
  // Color principal institucional (verde oliva oscuro)
  static const primary = Color(0xFF5A6000);
  // Tono más claro del color principal para acentos
  static const primaryLight = Color(0xFFC8D400);
  // Fondo oscuro para las pantallas
  static const bgDark = Color(0xFF3D4200);

  // Degradado semitransparente que se superpone al fondo con imagen
  static const gradientOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x44000000), // Oscuro arriba
      Color(0x00000000), // Transparente en medio
      Color(0x66000000), // Oscuro abajo
    ],
  );
}

// --- Estilos de texto reutilizables ---
class AppStyles {
  // Título principal en blanco
  static const titleWhite = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  // Subtítulo pequeño en blanco semitransparente
  static const subtitleWhite = TextStyle(
    color: Colors.white70,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1,
  );

  // Texto blanco negrita tamaño 15
  static const whiteBold16 = TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.bold,
  );

  // Texto blanco negrita tamaño 13
  static const whiteBold13 = TextStyle(
    color: Colors.white,
    fontSize: 13,
    fontWeight: FontWeight.bold,
  );

  // Texto blanco semitransparente tamaño 12
  static const white70_12 = TextStyle(
    color: Colors.white70,
    fontSize: 12,
  );

  // Texto blanco muy semitransparente tamaño 11
  static const white54_11 = TextStyle(
    color: Colors.white54,
    fontSize: 11,
  );
}
