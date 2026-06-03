import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/models/prestamo.dart';
import 'package:flutter_recursos_uts/models/solicitud.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/utils/icon_utils.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'package:flutter_recursos_uts/widgets/estado_badge.dart';
import 'package:flutter_recursos_uts/widgets/filter_chip_row.dart';
import 'package:flutter_recursos_uts/widgets/header_with_back.dart';
import 'package:flutter_recursos_uts/widgets/info_row.dart';
import 'package:flutter_recursos_uts/widgets/glass_card.dart';
import 'package:flutter_recursos_uts/widgets/stat_card.dart';

// Pantalla principal de "Mis Préstamos". Muestra la lista de préstamos del usuario
// con filtros por estado (TODOS, ACTIVOS, DEVUELTOS) y tarjetas de resumen
// con el conteo de activos, devueltos y vencidos.
class MisPrestamosScreen extends StatefulWidget {
  const MisPrestamosScreen({super.key});

  @override
  State<MisPrestamosScreen> createState() => _MisPrestamosScreenState();
}

class _MisPrestamosScreenState extends State<MisPrestamosScreen> {
  // Filtro de estado seleccionado actualmente en los chips (TODOS, ACTIVOS, DEVUELTOS)
  String _filtroSeleccionado = 'TODOS';
  // Opciones disponibles para el filtro de préstamos por estado
  final List<String> _filtros = ['TODOS', 'ACTIVOS', 'DEVUELTOS'];

  String? _nombre(AppProvider provider) => provider.usuarioActual?.nombre;

  List<Object> _obtenerItems(AppProvider provider) {
    final nombre = _nombre(provider) ?? '';
    final prestamos = provider.prestamos
        .where((p) => p.usuarioNombre == nombre).toList();
    if (_filtroSeleccionado == 'TODOS') {
      final solicitudes = provider.solicitudes
          .where((s) => s.usuarioNombre == nombre && s.estado == EstadoSolicitud.pendiente)
          .toList();
      return [...solicitudes, ...prestamos];
    }
    if (_filtroSeleccionado == 'ACTIVOS') {
      return prestamos.where((p) => p.estado == EstadoPrestamo.activo).toList();
    }
    return prestamos.where((p) => p.estado != EstadoPrestamo.activo).toList();
  }

  Color _colorEstadoString(String estado) {
    switch (estado) {
      case 'PENDIENTE': return Colors.orange;
      case 'ACTIVO': return Colors.greenAccent;
      case 'DEVUELTO': return Colors.white70;
      case 'VENCIDO': return Colors.redAccent;
      default: return Colors.white70;
    }
  }

  void _mostrarDetallePrestamo(Prestamo p) {
    final prov = context.read<AppProvider>();
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
          const SizedBox(height: 20),
          Container(width: 70, height: 70, decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
              child: Icon(getIcon(prov.iconoPorRecurso(p.recursoNombre)), size: 36,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          Text(p.recursoNombre, style: const TextStyle(color: Colors.white,
              fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 6),
          EstadoBadge(texto: p.estado.name.toUpperCase(),
              color: _colorEstadoString(p.estado.name.toUpperCase()), fontSize: 13),
          const SizedBox(height: 20),
          if (p.salon != null)
            InfoRow(icono: Icons.meeting_room, label: 'Salón',
                valor: '${p.salon} - ${p.equipo}'),
          InfoRow(icono: Icons.login, label: 'Préstamo',
              valor: '${p.fechaPrestamoStr}  ${p.fechaPrestamo.hour.toString().padLeft(2, '0')}:${p.fechaPrestamo.minute.toString().padLeft(2, '0')}'),
          InfoRow(icono: Icons.logout, label: 'Devolución',
              valor: '${p.fechaDevolucionStr}  ${p.fechaDevolucion.hour.toString().padLeft(2, '0')}:${p.fechaDevolucion.minute.toString().padLeft(2, '0')}'),
          if (p.accesorios.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Align(alignment: Alignment.centerLeft,
                child: Text('ACCESORIOS:', style: TextStyle(
                    color: Colors.white70, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 1))),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8,
                children: p.accesorios.map((acc) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white38)),
                  child: Text(acc, style: const TextStyle(
                      color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.bold)),
                )).toList()),
          ],
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _mostrarDetalleSolicitud(Solicitud s) {
    final prov = context.read<AppProvider>();
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
          const SizedBox(height: 20),
          Container(width: 70, height: 70, decoration: const BoxDecoration(
              color: Colors.white, shape: BoxShape.circle),
              child: Icon(getIcon(prov.iconoPorRecurso(s.recursoNombre)), size: 36,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          Text(s.recursoNombre, style: const TextStyle(color: Colors.white,
              fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 6),
          EstadoBadge(texto: s.estado.name.toUpperCase(),
              color: _colorEstadoString(s.estado.name.toUpperCase()), fontSize: 13),
          const SizedBox(height: 20),
          if (s.salon != null)
            InfoRow(icono: Icons.meeting_room, label: 'Salón',
                valor: '${s.salon} - ${s.equipo}'),
          InfoRow(icono: Icons.login, label: 'Préstamo',
              valor: '${s.fechaPrestamoStr}  ${s.fechaPrestamo.hour.toString().padLeft(2, '0')}:${s.fechaPrestamo.minute.toString().padLeft(2, '0')}'),
          InfoRow(icono: Icons.logout, label: 'Devolución',
              valor: '${s.fechaDevolucionStr}  ${s.fechaDevolucion.hour.toString().padLeft(2, '0')}:${s.fechaDevolucion.minute.toString().padLeft(2, '0')}'),
          if (s.accesorios.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Align(alignment: Alignment.centerLeft,
                child: Text('ACCESORIOS:', style: TextStyle(
                    color: Colors.white70, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 1))),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8,
                children: s.accesorios.map((acc) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white38)),
                  child: Text(acc, style: const TextStyle(
                      color: Colors.white, fontSize: 12,
                      fontWeight: FontWeight.bold)),
                )).toList()),
          ],
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final items = _obtenerItems(provider);
    final nombre = _nombre(provider) ?? '';
    final totales = provider.prestamos
        .where((p) => p.usuarioNombre == nombre).toList();
    final activos = totales
        .where((p) => p.estado == EstadoPrestamo.activo).length;
    final vencidos = totales
        .where((p) => p.estado == EstadoPrestamo.vencido).length;
    final pendientes = provider.solicitudes
        .where((s) => s.usuarioNombre == nombre && s.estado == EstadoSolicitud.pendiente).length;

    return BackgroundScaffold(
      child: SafeArea(
        child: Column(children: [
          const HeaderWithBack(titulo: 'MIS PRÉSTAMOS'),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              StatCard(label: 'PENDIENTES', valor: '$pendientes',
                  color: Colors.orange),
              const SizedBox(width: 10),
              StatCard(label: 'ACTIVOS', valor: '$activos',
                  color: Colors.greenAccent),
              const SizedBox(width: 10),
              StatCard(label: 'VENCIDOS', valor: '$vencidos',
                  color: Colors.redAccent),
            ]),
          ),
          const SizedBox(height: 16),
          FilterChipRow(
            filtros: _filtros, seleccionado: _filtroSeleccionado,
            onChanged: (f) => setState(() => _filtroSeleccionado = f)),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No hay préstamos aquí',
                    style: TextStyle(color: Colors.white70, fontSize: 15)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = items[i];
                      if (item is Solicitud) {
                        final s = item;
                        return GestureDetector(
                          onTap: () => _mostrarDetalleSolicitud(s),
                          child: GlassCard(
                            child: Row(children: [
                              Container(width: 56, height: 56,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
child: Icon(getIcon(provider.iconoPorRecurso(s.recursoNombre)), size: 28,
                                    color: AppColors.primary)),
                              const SizedBox(width: 14),
                              Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(s.recursoNombre, style: AppStyles.whiteBold16),
                                      EstadoBadge(
                                          texto: s.estado.name.toUpperCase(),
                                          color: _colorEstadoString(s.estado.name.toUpperCase())),
                                    ]),
                                const SizedBox(height: 4),
                                Text('${s.fechaPrestamoStr}  ${s.fechaPrestamo.hour.toString().padLeft(2, '0')}:${s.fechaPrestamo.minute.toString().padLeft(2, '0')}',
                                    style: AppStyles.white70_12),
                                if (s.accesorios.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text('+ ${s.accesorios.join(', ')}',
                                      style: AppStyles.white54_11,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ])),
                              const Icon(Icons.chevron_right, color: Colors.white54),
                            ]),
                          ),
                        );
                      }
                      final p = item as Prestamo;
                      return GestureDetector(
                        onTap: () => _mostrarDetallePrestamo(p),
                        child: GlassCard(
                          child: Row(children: [
                            Container(width: 56, height: 56,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Icon(getIcon(provider.iconoPorRecurso(p.recursoNombre)), size: 28,
                                    color: AppColors.primary)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(p.recursoNombre, style: AppStyles.whiteBold16),
                                    EstadoBadge(
                                        texto: p.estado.name.toUpperCase(),
                                        color: _colorEstadoString(p.estado.name.toUpperCase())),
                                  ]),
                              const SizedBox(height: 4),
                              Text('${p.fechaPrestamoStr}  ${p.fechaPrestamo.hour.toString().padLeft(2, '0')}:${p.fechaPrestamo.minute.toString().padLeft(2, '0')}',
                                  style: AppStyles.white70_12),
                              if (p.accesorios.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text('+ ${p.accesorios.join(', ')}',
                                    style: AppStyles.white54_11,
                                    overflow: TextOverflow.ellipsis),
                              ],
                            ])),
                            const Icon(Icons.chevron_right, color: Colors.white54),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
