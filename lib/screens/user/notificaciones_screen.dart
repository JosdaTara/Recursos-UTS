// Pantalla que lista todas las notificaciones del sistema (aprobadas, recordatorios, vencidas).
// Al abrirse, genera alertas actualizadas para préstamos próximos a vencer o vencidos.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/models/notificacion.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    // Actualiza las alertas al entrar a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().actualizarAlertas();
    });
  }

  // Retorna el color según el tipo de notificación
  Color _colorTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.aprobado: return Colors.green;
      case TipoNotificacion.recordatorio: return Colors.orange;
      case TipoNotificacion.vencido: return Colors.red;
    }
  }

  // Retorna el icono según el tipo de notificación
  IconData _iconoTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.aprobado: return Icons.check_circle;
      case TipoNotificacion.recordatorio: return Icons.access_time;
      case TipoNotificacion.vencido: return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final notificaciones = provider.notificaciones;
    final noLeidas = provider.notificacionesNoLeidas;

    return BackgroundScaffold(
      backgroundColor: AppColors.bgDark,
      child: SafeArea(
        child: Column(children: [
          const SizedBox(height: 24),
          // Encabezado con badge de no leídas
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('NOTIFICACIONES', style: TextStyle(color: Colors.white,
                fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            if (noLeidas > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(20)),
                child: Text('$noLeidas', style: const TextStyle(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.bold)),
              ),
            ],
          ]),
          const SizedBox(height: 20),
          // Lista de notificaciones o mensaje vacío
          Expanded(
            child: notificaciones.isEmpty
                ? const Center(child: Text('No tienes notificaciones',
                    style: TextStyle(color: Colors.white70, fontSize: 16)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: notificaciones.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final n = notificaciones[i];
                      return GestureDetector(
                        // Al tocar se marca como leída
                        onTap: () => provider.marcarNotificacionLeida(i),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            // No leída se ve más brillante
                            color: n.leida
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: n.leida
                                ? Colors.white30 : Colors.white70, width: 1.5)),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            // Círculo con icono según tipo
                            Container(width: 50, height: 50,
                                decoration: BoxDecoration(
                                  color: _colorTipo(n.tipo).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: _colorTipo(n.tipo), width: 2)),
                                child: Icon(_iconoTipo(n.tipo),
                                    color: _colorTipo(n.tipo), size: 26)),
                            const SizedBox(width: 12),
                            // Título, mensaje y hora
                            Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(n.titulo, style: TextStyle(
                                        color: Colors.white, fontSize: 15,
                                        fontWeight: n.leida
                                            ? FontWeight.normal
                                            : FontWeight.bold)),
                                    if (!n.leida)
                                      Container(width: 10, height: 10,
                                          decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle)),
                                  ]),
                              const SizedBox(height: 4),
                              Text(n.mensaje, style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(n.hora, style: const TextStyle(
                                  color: Colors.white54, fontSize: 11)),
                            ])),
                            // Botón para eliminar
                            IconButton(
                                onPressed: () =>
                                    provider.eliminarNotificacion(i),
                                icon: const Icon(Icons.close,
                                    color: Colors.white54, size: 18)),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
          // Botón de retroceso
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 24, top: 8),
            child: Align(alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context, noLeidas),
                  child: const Icon(Icons.arrow_back,
                      color: Colors.white70, size: 44))),
          ),
        ]),
      ),
    );
  }
}
