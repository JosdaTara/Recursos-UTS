// Fila horizontal de chips para filtrar contenido (ej: filtrar recursos por categoría).
import 'package:flutter/material.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';

class FilterChipRow extends StatelessWidget {
  final List<String> filtros;           // Lista de nombres de filtros
  final String seleccionado;            // Filtro actualmente activo
  final ValueChanged<String> onChanged; // Callback al seleccionar un filtro

  const FilterChipRow({
    super.key,
    required this.filtros,
    required this.seleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filtros.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final f = filtros[i];
          final sel = seleccionado == f;
          return GestureDetector(
            onTap: () => onChanged(f),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                // Filtro seleccionado usa el color primario; los demás son semitransparentes
                color: sel
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: sel ? AppColors.primary : Colors.white54,
                ),
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
