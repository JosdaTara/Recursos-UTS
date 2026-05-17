import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/models/solicitud.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
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
  // Filtro activo actualmente: PENDIENTES, APROBADAS o RECHAZADAS
  String _filtro = 'PENDIENTES';
  // Lista de opciones de filtro disponibles
  final List<String> _filtros = ['PENDIENTES', 'APROBADAS', 'RECHAZADAS'];

  // Filtra la lista de solicitudes según el filtro seleccionado
  List<Solicitud> _solicitudesFiltradas(AppProvider provider) {
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
                child: Icon(s.recursoIcono, size: 34,
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
                  onPressed: () {
                    provider.rechazarSolicitud(index);
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
                  onPressed: () {
                    provider.aprobarSolicitud(index);
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

  @override
  // Construye la interfaz con header, filtros y lista de solicitudes
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filtradas = _solicitudesFiltradas(provider);
    final pendientes = provider.solicitudesPendientes;

    // Contenedor principal con fondo, encabezado y contador de pendientes
    return BackgroundScaffold(
      child: SafeArea(
        child: Column(children: [
          HeaderWithBack(
            titulo: 'SOLICITUDES',
            trailing: pendientes > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange, width: 1.5)),
                    child: Text('$pendientes pendientes',
                        style: const TextStyle(color: Colors.orange, fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  )
                : null,
          ),
          const SizedBox(height: 20),
          // Fila de chips para filtrar por estado
          FilterChipRow(
            filtros: _filtros, seleccionado: _filtro,
            onChanged: (f) => setState(() => _filtro = f)),
          const SizedBox(height: 16),
          // Lista de solicitudes filtradas o mensaje vacío
          Expanded(
            child: filtradas.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_filtro == 'PENDIENTES'
                          ? Icons.check_circle_outline
                          : Icons.inbox,
                          color: Colors.white38, size: 60),
                      const SizedBox(height: 12),
                      Text(_filtro == 'PENDIENTES'
                          ? '¡Todo al día!'
                          : 'No hay solicitudes aquí',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 15)),
                    ]))
                // Lista de solicitudes con GlassCard por cada una
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtradas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final s = filtradas[i];
                      final index = provider.solicitudes.indexOf(s);
                      return GestureDetector(
                        onTap: () => _mostrarDetalle(s, index, provider),
                        child: GlassCard(
                          child: Row(children: [
                            Container(width: 52, height: 52,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Icon(s.recursoIcono, size: 26,
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
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}
