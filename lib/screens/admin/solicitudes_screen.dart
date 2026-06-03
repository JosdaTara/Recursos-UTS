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
import 'package:flutter_recursos_uts/widgets/glass_card.dart';
import 'package:flutter_recursos_uts/widgets/header_with_back.dart';
import 'package:flutter_recursos_uts/widgets/info_row.dart';
import 'package:flutter_recursos_uts/widgets/section_divider.dart';

class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

// =============================================================================
// Pantalla de gestión de solicitudes de préstamo.
// Permite al administrador ver, filtrar, aprobar y rechazar solicitudes
// de préstamo de recursos hechas por los usuarios.
// =============================================================================
class _SolicitudesScreenState extends State<SolicitudesScreen> {
  String _filtro = 'PENDIENTES';
  final List<String> _filtros = ['PENDIENTES', 'APROBADAS', 'RECHAZADAS', 'ACTIVOS'];

  List<dynamic> _itemsFiltrados(AppProvider provider) {
    if (_filtro == 'ACTIVOS') {
      return provider.prestamos
          .where((p) => p.estado == EstadoPrestamo.activo)
          .toList();
    }
    if (_filtro == 'PENDIENTES') {
      return provider.solicitudes
          .where((s) => s.estado == EstadoSolicitud.pendiente)
          .toList();
    } else if (_filtro == 'APROBADAS') {
      return provider.solicitudes
          .where((s) => s.estado == EstadoSolicitud.aprobada)
          .toList();
    }
    return provider.solicitudes
        .where((s) => s.estado == EstadoSolicitud.rechazada)
        .toList();
  }

  // Devuelve un color según el estado de la solicitud (pendiente/aprobada/rechazada)
  Color _colorEstado(EstadoSolicitud estado) {
    switch (estado) {
      case EstadoSolicitud.pendiente:
        return Colors.orange;
      case EstadoSolicitud.aprobada:
        return Colors.greenAccent;
      case EstadoSolicitud.rechazada:
        return Colors.redAccent;
    }
  }

  // Muestra un BottomSheet con el detalle completo de la solicitud
  // y los botones para aprobar/rechazar si está pendiente
  void _mostrarDetalle(Solicitud s, int index, AppProvider provider) {
    final pendiente = s.estado == EstadoSolicitud.pendiente;
    // BottomSheet con información del solicitante, préstamo, accesorios y acciones
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white38,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(width: 65, height: 65,
                decoration: const BoxDecoration(color: Colors.white,
                    shape: BoxShape.circle),
                child: Icon(getIcon(provider.iconoPorRecurso(s.recursoNombre)), size: 34,
                    color: AppColors.primary)),
            const SizedBox(height: 12),
            Text(s.recursoNombre, style: const TextStyle(color: Colors.white,
                fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            EstadoBadge(
              texto: s.estado.name.toUpperCase(),
              color: _colorEstado(s.estado),
              fontSize: 13,
            ),
            const SizedBox(height: 20),
            SectionDivider(titulo: 'DATOS DEL SOLICITANTE'),
            const SizedBox(height: 8),
            InfoRow(icono: Icons.person_outline, label: 'Usuario', valor: s.usuarioNombre),
            InfoRow(icono: Icons.badge_outlined, label: 'Documento', valor: s.documento),
            InfoRow(icono: Icons.school_outlined, label: 'Programa', valor: s.programa),
            const SizedBox(height: 12),
            SectionDivider(titulo: 'DETALLES DEL PRÉSTAMO'),
            const SizedBox(height: 8),
            if (s.salon != null)
              InfoRow(icono: Icons.meeting_room, label: 'Salón',
                  valor: '${s.salon} - ${s.equipo}'),
            InfoRow(icono: Icons.login, label: 'Préstamo',
                valor: '${s.fechaPrestamoStr}  ${s.fechaPrestamo.hour.toString().padLeft(2, '0')}:${s.fechaPrestamo.minute.toString().padLeft(2, '0')}'),
            InfoRow(icono: Icons.logout, label: 'Devolución',
                valor: '${s.fechaDevolucionStr}  ${s.fechaDevolucion.hour.toString().padLeft(2, '0')}:${s.fechaDevolucion.minute.toString().padLeft(2, '0')}'),
            InfoRow(icono: Icons.access_time, label: 'Solicitado', valor: s.fechaSolicitudStr),
            if (s.accesorios.isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionDivider(titulo: 'ACCESORIOS'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                  children: s.accesorios.map((acc) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white38)),
                    child: Text(acc, style: const TextStyle(color: Colors.white,
                        fontSize: 12, fontWeight: FontWeight.bold)),
                  )).toList()),
            ],
            const SizedBox(height: 20),
            if (pendiente)
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () async {
                    await provider.rechazarSolicitud(index);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Solicitud rechazada'),
                          backgroundColor: Colors.red));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(), elevation: 0),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('RECHAZAR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton.icon(
                  onPressed: () async {
                    await provider.aprobarSolicitud(index);
                    if (!mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Solicitud aprobada'),
                          backgroundColor: AppColors.primary));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(), elevation: 0),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('APROBAR',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )),
              ]),
            const SizedBox(height: 8),
          ]),
        );
      },
    );
  }

  void _mostrarDetallePrestamo(Prestamo p, AppProvider provider) {
    final vencido = p.fechaDevolucion.isBefore(DateTime.now());
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.white38,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Container(width: 65, height: 65,
              decoration: const BoxDecoration(color: Colors.white,
                  shape: BoxShape.circle),
              child: Icon(getIcon(provider.iconoPorRecurso(p.recursoNombre)), size: 34,
                  color: AppColors.primary)),
          const SizedBox(height: 12),
          Text(p.recursoNombre, style: const TextStyle(color: Colors.white,
              fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          EstadoBadge(
            texto: vencido ? 'VENCIDO' : 'ACTIVO',
            color: vencido ? Colors.redAccent : Colors.orange,
            fontSize: 13,
          ),
          const SizedBox(height: 20),
          SectionDivider(titulo: 'DATOS DEL PRÉSTAMO'),
          const SizedBox(height: 8),
          InfoRow(icono: Icons.person_outline, label: 'Usuario', valor: p.usuarioNombre),
          if (p.salon != null)
            InfoRow(icono: Icons.meeting_room, label: 'Salón',
                valor: '${p.salon} - ${p.equipo}'),
          InfoRow(icono: Icons.login, label: 'Inicio',
              valor: '${p.fechaPrestamoStr}  ${p.fechaPrestamo.hour.toString().padLeft(2, '0')}:${p.fechaPrestamo.minute.toString().padLeft(2, '0')}'),
          InfoRow(icono: Icons.logout, label: 'Tope devolución',
              valor: '${p.fechaDevolucionStr}  ${p.fechaDevolucion.hour.toString().padLeft(2, '0')}:${p.fechaDevolucion.minute.toString().padLeft(2, '0')}'),
          if (p.accesorios.isNotEmpty) ...[
            const SizedBox(height: 12),
            SectionDivider(titulo: 'ACCESORIOS'),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8,
                children: p.accesorios.map((acc) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white38)),
                  child: Text(acc, style: const TextStyle(color: Colors.white,
                      fontSize: 12, fontWeight: FontWeight.bold)),
                )).toList()),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await provider.devolverPrestamo(p);
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Devolución registrada'),
                      backgroundColor: Colors.green));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const StadiumBorder(), elevation: 0),
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text('REGISTRAR DEVOLUCIÓN',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filtradas = _itemsFiltrados(provider);

    return BackgroundScaffold(
      child: SafeArea(
        child: Column(children: [
          HeaderWithBack(titulo: 'SOLICITUDES'),
          const SizedBox(height: 20),
          FilterChipRow(
            filtros: _filtros, seleccionado: _filtro,
            onChanged: (f) => setState(() => _filtro = f)),
          const SizedBox(height: 16),
          Expanded(
            child: filtradas.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_filtro == 'ACTIVOS'
                          ? Icons.check_circle_outline
                          : _filtro == 'PENDIENTES'
                              ? Icons.check_circle_outline
                              : Icons.inbox,
                          color: Colors.white38, size: 60),
                      const SizedBox(height: 12),
                      Text(_filtro == 'ACTIVOS'
                          ? 'No hay préstamos activos'
                          : _filtro == 'PENDIENTES'
                              ? '¡Todo al día!'
                              : 'No hay solicitudes aquí',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15)),
                    ]))
                : RefreshIndicator(
                    onRefresh: () => context.read<AppProvider>().refrescarDatos(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtradas.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                      final item = filtradas[i];
                      if (item is Prestamo) {
                        return GestureDetector(
                          onTap: () => _mostrarDetallePrestamo(item, provider),
                          child: GlassCard(
                            child: Row(children: [
                              Container(width: 52, height: 52,
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle),
                                  child: Icon(getIcon(provider.iconoPorRecurso(item.recursoNombre)), size: 26,
                                      color: AppColors.primary)),
                              const SizedBox(width: 14),
                              Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(item.recursoNombre,
                                    style: AppStyles.whiteBold16),
                                const SizedBox(height: 4),
                                Text(item.usuarioNombre, style: AppStyles.white70_12),
                                Text('Dev: ${item.fechaDevolucionStr}',
                                    style: AppStyles.white54_11),
                              ])),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.greenAccent)),
                                child: const Text('ACTIVO',
                                    style: TextStyle(color: Colors.greenAccent,
                                        fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ]),
                          ),
                        );
                      }
                      final s = item as Solicitud;
                      final index = provider.solicitudes.indexOf(s);
                      return GestureDetector(
                        onTap: () => _mostrarDetalle(s, index, provider),
                        child: GlassCard(
                          child: Row(children: [
                            Container(width: 52, height: 52,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Icon(getIcon(provider.iconoPorRecurso(s.recursoNombre)), size: 26,
                                    color: AppColors.primary)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(s.recursoNombre,
                                        style: AppStyles.whiteBold16),
                                    EstadoBadge(
                                        texto: s.estado.name.toUpperCase(),
                                        color: _colorEstado(s.estado)),
                                  ]),
                              const SizedBox(height: 4),
                              Text(s.usuarioNombre, style: AppStyles.white70_12),
                              Text('Solicitado: ${s.fechaSolicitudStr}',
                                  style: AppStyles.white54_11),
                            ])),
                            const Icon(Icons.chevron_right,
                                color: Colors.white54),
                          ]),
                        ),
                      );
                    },
                    ),
                  ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
