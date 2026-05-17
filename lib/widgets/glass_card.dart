// Widget de tarjeta semitransparente con efecto "vidrio esmerilado".
// Se usa para agrupar contenido sobre el fondo oscuro de forma elegante.
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;                   // Contenido interno
  final EdgeInsetsGeometry padding;     // Espaciado interno (default 16)
  final double borderRadius;            // Esquinas redondeadas (default 18)
  final double borderOpacity;           // Opacidad del borde (default 0.3)
  final EdgeInsetsGeometry? margin;     // Margen externo (opcional)

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 18,
    this.borderOpacity = 0.3,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        // Fondo blanco semitransparente para efecto glass
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: Colors.white.withValues(alpha: borderOpacity),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}
