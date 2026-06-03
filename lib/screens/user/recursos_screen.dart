import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/models/equipo.dart';
import 'package:flutter_recursos_uts/models/recurso.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/utils/icon_utils.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'package:flutter_recursos_uts/widgets/filter_chip_row.dart';
import 'package:flutter_recursos_uts/widgets/glass_card.dart';
import 'package:flutter_recursos_uts/widgets/header_with_back.dart';

// Pantalla de exploración de recursos disponibles. Muestra equipos
// por salón con indicadores de disponibilidad y una lista de otros
// recursos (cables, accesorios). Incluye filtro por categoría.
class RecursosScreen extends StatefulWidget {
  const RecursosScreen({super.key});

  @override
  State<RecursosScreen> createState() => _RecursosScreenState();
}

class _RecursosScreenState extends State<RecursosScreen> {
  // Categoría seleccionada actualmente en el filtro (TODOS, EQUIPOS, CABLES, OTROS)
  String _categoriaSeleccionada = 'TODOS';
  // Opciones de categorías disponibles para filtrar recursos
  final List<String> _categorias = ['TODOS', 'EQUIPOS', 'CABLES', 'OTROS'];

  // Filtra la lista de recursos según la categoría seleccionada (TODOS, EQUIPOS, CABLES, OTROS)
  List<Recurso> _recursosFiltrados(AppProvider provider) {
    if (_categoriaSeleccionada == 'TODOS') return provider.recursos;
    final cat = _categoriaSeleccionada == 'EQUIPOS'
        ? CategoriaRecurso.equipos
        : _categoriaSeleccionada == 'CABLES'
            ? CategoriaRecurso.cables
            : CategoriaRecurso.otros;
    return provider.recursos.where((r) => r.categoria == cat).toList();
  }

  // Retorna un color según el porcentaje de disponibilidad:
  // rojo (<=30%), naranja (<=60%), verde (>60%)
  Color _colorDisponibilidad(int disponible, int total) {
    final p = total > 0 ? disponible / total : 0.0;
    if (p <= 0.3) return Colors.red;
    if (p <= 0.6) return Colors.orange;
    return Colors.greenAccent;
  }

  // Muestra un modal bottom sheet con los equipos de un salón y su estado (disponible/ocupado)
  void _mostrarDetallesSalon(String salon, List<Equipo> equipos) {
    final disponibles = equipos.where((e) => e.disponible).length;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.white38, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Text(salon, style: const TextStyle(color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('$disponibles de ${equipos.length} disponibles',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 3, shrinkWrap: true, crossAxisSpacing: 10,
            mainAxisSpacing: 10, childAspectRatio: 1.8,
            children: equipos.map((e) {
              final disp = e.disponible;
               return Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: disp ? AppColors.primaryLight : Colors.redAccent,
                      width: 1.5)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.computer,
                      color: disp ? AppColors.primaryLight : Colors.redAccent,
                      size: 18),
                  const SizedBox(height: 2),
                   Text(e.nombre, style: TextStyle(
                      color: disp ? AppColors.primaryLight : Colors.redAccent,
                      fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(disp ? 'Libre' : 'Ocupado', style: TextStyle(
                      color: disp ? AppColors.primaryLight : Colors.redAccent,
                      fontSize: 10)),
                ]),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filtrados = _recursosFiltrados(provider);
    final equiposDisponibles = filtrados
        .where((r) => r.categoria == CategoriaRecurso.equipos &&
            r.nombre != 'COMPUTADOR')
        .toList();
    final otros = filtrados
        .where((r) => r.categoria != CategoriaRecurso.equipos)
        .toList();

    return BackgroundScaffold(
      child: SafeArea(
        child: Column(children: [
          const HeaderWithBack(titulo: 'VER RECURSOS'),
          const SizedBox(height: 20),
          FilterChipRow(
            filtros: _categorias, seleccionado: _categoriaSeleccionada,
            onChanged: (f) => setState(() => _categoriaSeleccionada = f)),
          const SizedBox(height: 16),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              if (_categoriaSeleccionada == 'TODOS' ||
                  _categoriaSeleccionada == 'EQUIPOS') ...[
                const Text('COMPUTADORES POR SALÓN',
                    style: AppStyles.subtitleWhite),
                const SizedBox(height: 10),
                ...provider.salones.entries.map((entry) {
                  final disponibles = entry.value
                      .where((e) => e.disponible).length;
                  final total = entry.value.length;
                  return GestureDetector(
                    onTap: () => _mostrarDetallesSalon(
                        entry.key, entry.value),
                    child: GlassCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      borderRadius: 16,
                      child: Row(children: [
                        Container(width: 50, height: 50,
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.computer,
                                color: AppColors.primary, size: 26)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(entry.key, style: AppStyles.whiteBold16),
                          const SizedBox(height: 4),
                          Row(children: [
                            Text('$disponibles disponibles',
                                style: TextStyle(
                                    color: _colorDisponibilidad(
                                        disponibles, total),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                            Text(' de $total equipos',
                                style: AppStyles.white70_12),
                          ]),
                          const SizedBox(height: 6),
                          ClipRRect(borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: total > 0 ? disponibles / total : 0,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _colorDisponibilidad(disponibles, total)),
                                minHeight: 6)),
                        ])),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right, color: Colors.white54),
                      ]),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
              if (equiposDisponibles.isNotEmpty &&
                  (_categoriaSeleccionada == 'TODOS' ||
                      _categoriaSeleccionada == 'EQUIPOS')) ...[
                const Text('EQUIPOS DISPONIBLES',
                    style: AppStyles.subtitleWhite),
                const SizedBox(height: 10),
                ...equiposDisponibles.map((r) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  borderRadius: 16,
                  child: Row(children: [
                    Container(width: 50, height: 50,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(getIcon(r.icono),
                            color: AppColors.primary, size: 26)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(r.nombre, style: AppStyles.whiteBold16),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text('${r.disponible} disponibles',
                            style: TextStyle(
                                color: _colorDisponibilidad(
                                    r.disponible, r.total),
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                        Text(' de ${r.total}', style: AppStyles.white70_12),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: r.porcentajeDisponible,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _colorDisponibilidad(r.disponible, r.total)),
                            minHeight: 6)),
                    ])),
                  ]),
                )),
                const SizedBox(height: 16),
              ],
              if (otros.isNotEmpty) ...[
                const Text('OTROS RECURSOS', style: AppStyles.subtitleWhite),
                const SizedBox(height: 10),
                ...otros.map((r) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 10),
                  borderRadius: 16,
                  child: Row(children: [
                    Container(width: 50, height: 50,
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(getIcon(r.icono), color: AppColors.primary, size: 26)),
                    const SizedBox(width: 14),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.nombre, style: AppStyles.whiteBold16),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text('${r.disponible} disponibles',
                            style: TextStyle(
                                color: _colorDisponibilidad(r.disponible, r.total),
                                fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(' de ${r.total}', style: AppStyles.white70_12),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: r.porcentajeDisponible,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _colorDisponibilidad(r.disponible, r.total)),
                            minHeight: 6)),
                    ])),
                  ]),
                )),
              ],
              const SizedBox(height: 24),
            ]),
          )),
        ]),
      ),
    );
  }
}
