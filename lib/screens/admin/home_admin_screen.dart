// Pantalla principal del panel de administración.
// Muestra un saludo de bienvenida, alertas importantes (solicitudes pendientes,
// préstamos por vencer, préstamos activos), un resumen general con tarjetas
// estadísticas, el recurso más prestado del mes, y las opciones de gestión
// (solicitudes, recursos, usuarios, historial, escáner). Incluye botón para
// cerrar sesión y notificaciones.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'package:flutter_recursos_uts/widgets/glass_card.dart';
import 'package:flutter_recursos_uts/screens/user/notificaciones_screen.dart';
import 'solicitudes_screen.dart';
import 'gestion_recursos_screen.dart';
import 'gestion_usuarios_screen.dart';
import 'historial_screen.dart';
import 'escaner_screen.dart';

class HomeAdminScreen extends StatelessWidget {
  const HomeAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return BackgroundScaffold(
      backgroundColor: AppColors.bgDark,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(provider, context),
              const SizedBox(height: 24),
              _buildAlertas(provider),
              const SizedBox(height: 24),
              _buildResumen(provider),
              const SizedBox(height: 24),
              _buildRecursoMasPrestado(provider),
              const SizedBox(height: 24),
              _buildGestion(context, provider),
              const SizedBox(height: 24),
              _buildLogout(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppProvider provider, BuildContext context) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PANEL DE ADMINISTRACIÓN',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                const Text('Bienvenido, Administrador',
                    style: TextStyle(color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificacionesScreen())),
            child: Stack(children: [
              const Icon(Icons.notifications, color: Colors.white70, size: 32),
              if (provider.notificacionesNoLeidas > 0)
                Positioned(top: 0, right: 0,
                    child: Container(width: 16, height: 16,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: Center(child: Text('${provider.notificacionesNoLeidas}',
                            style: const TextStyle(color: Colors.white,
                                fontSize: 10, fontWeight: FontWeight.bold))))),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertas(AppProvider provider) {
    final alerts = <Widget>[];
    if (provider.solicitudesPendientes > 0) {
      alerts.add(_alertaCard(
        icono: Icons.assignment_late,
        mensaje: '${provider.solicitudesPendientes} solicitudes pendientes sin revisar',
        color: Colors.orange,
        solidColor: Colors.orange.withValues(alpha: 0.25),
      ));
    }
    if (provider.prestamosProximosAVencer > 0) {
      alerts.add(const SizedBox(height: 8));
      alerts.add(_alertaCard(
        icono: Icons.access_time,
        mensaje: '${provider.prestamosProximosAVencer} préstamo(s) por vencer (próximas 2h)',
        color: Colors.amber,
      ));
    }
    if (provider.prestamosActivos > 0) {
      alerts.add(const SizedBox(height: 8));
      alerts.add(_alertaCard(
        icono: Icons.check_circle,
        mensaje: '${provider.prestamosActivos} préstamo activo sin devolver',
        color: const Color(0xFF66BB6A),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.notifications_active, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          const Text('ALERTAS', style: AppStyles.subtitleWhite),
        ]),
        const SizedBox(height: 10),
        if (alerts.isEmpty)
          _alertaCard(
            icono: Icons.check_circle,
            mensaje: 'Todo en orden, sin alertas',
            color: Colors.greenAccent,
          )
        else
          ...alerts,
      ],
    );
  }

  Widget _buildResumen(AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.bar_chart, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          const Text('RESUMEN GENERAL', style: AppStyles.subtitleWhite),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _statCard(
            icono: Icons.assignment,
            label: 'SOLICITUDES PENDIENTES',
            valor: '${provider.solicitudesPendientes}',
          ),
          const SizedBox(width: 10),
          _statCard(
            icono: Icons.swap_horiz,
            label: 'PRÉSTAMOS ACTIVOS',
            valor: '${provider.prestamosActivos}',
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _statCard(
            icono: Icons.inventory_2,
            label: 'RECURSOS DISPONIBLES',
            valor: '${provider.recursosDisponibles}',
          ),
          const SizedBox(width: 10),
          _statCard(
            icono: Icons.people,
            label: 'USUARIOS REGISTRADOS',
            valor: '${provider.usuarios.length}',
          ),
        ]),
      ],
    );
  }

  Widget _statCard({
    required IconData icono,
    required String label,
    required String valor,
  }) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 16,
        child: Row(children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, color: AppColors.primaryLight, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(valor,
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ],
          )),
        ]),
      ),
    );
  }

  Widget _buildRecursoMasPrestado(AppProvider provider) {
    final mas = provider.recursoMasPrestado();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.trending_up, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          const Text('RECURSO MÁS PRESTADO', style: AppStyles.subtitleWhite),
        ]),
        const SizedBox(height: 10),
        GlassCard(
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.5)),
              ),
              child: Icon(mas['icono'] as IconData,
                  color: AppColors.primaryLight, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(mas['nombre'] as String, style: AppStyles.whiteBold16),
              const SizedBox(height: 2),
              Text('${mas['cantidad']} préstamos este mes',
                  style: AppStyles.white70_12),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: mas['porcentaje'] as double,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryLight),
                    minHeight: 6)),
            ])),
          ]),
        ),
      ],
    );
  }

  Widget _buildGestion(BuildContext context, AppProvider provider) {
    final items = [
      _GestItem(
        icono: Icons.assignment,
        titulo: 'SOLICITUDES',
        subtitulo: '${provider.solicitudesPendientes} pendientes',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SolicitudesScreen())),
      ),
      _GestItem(
        icono: Icons.inventory_2,
        titulo: 'RECURSOS',
        subtitulo: 'Agregar, editar, eliminar',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const GestionRecursosScreen())),
      ),
      _GestItem(
        icono: Icons.people,
        titulo: 'USUARIOS',
        subtitulo: 'Ver y administrar',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const GestionUsuariosScreen())),
      ),
      _GestItem(
        icono: Icons.history,
        titulo: 'HISTORIAL',
        subtitulo: 'Préstamos y devoluciones',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const HistorialScreen())),
      ),
      _GestItem(
        icono: Icons.qr_code_scanner,
        titulo: 'ESCANEAR',
        subtitulo: 'Código de barras',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EscanerScreen())),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.widgets, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          const Text('GESTIÓN', style: AppStyles.subtitleWhite),
        ]),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _opcionCard(item, context),
        )),
      ],
    );
  }

  Widget _opcionCard(_GestItem item, BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: GlassCard(
        borderRadius: 16,
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.5)),
            ),
            child: Icon(item.icono, color: AppColors.primaryLight, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.titulo, style: AppStyles.whiteBold16),
            const SizedBox(height: 3),
            Text(item.subtitulo,
                style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ])),
          const Icon(Icons.chevron_right, color: Colors.white54),
        ]),
      ),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context, '/login', (route) => false),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text('CERRAR SESIÓN', style: TextStyle(
            fontWeight: FontWeight.bold, letterSpacing: 1.2)),
      ),
    );
  }

  Widget _alertaCard({
    required IconData icono,
    required String mensaje,
    required Color color,
    Color? solidColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: solidColor ?? Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(children: [
        Icon(icono, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Text(mensaje, style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.bold))),
      ]),
    );
  }
}

class _GestItem {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _GestItem({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });
}
