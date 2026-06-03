// Pantalla principal de inicio del usuario.
// Muestra el logo, un mensaje de bienvenida y botones para acceder
// al menú de navegación y a las notificaciones.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'menu_screen.dart';
import 'notificaciones_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Abre el menú lateral con una animación de transición fade
  void _abrirMenu() {
    Navigator.push(context, PageRouteBuilder(
      opaque: false,
      pageBuilder: (_, _, _) => const MenuScreen(),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ));
  }

  // Abre la pantalla de notificaciones y refresca el estado al regresar
  void _abrirNotificaciones() async {
    await Navigator.push(context,
        MaterialPageRoute(builder: (_) => const NotificacionesScreen()));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final noLeidas = provider.notificacionesNoLeidas;
    return BackgroundScaffold(
      backgroundColor: AppColors.bgDark,
      child: SafeArea(
        child: Column(children: [
          const Spacer(),
          // Sección del logo de la aplicación
          Column(children: [
            Image.asset('assets/logo.png',
                width: MediaQuery.of(context).size.width * 0.6),
            const SizedBox(height: 8),
          ]),
          const SizedBox(height: 48),
          // Mensaje de bienvenida al usuario
          Text('BIENVENIDO\n${provider.usuarioActual?.nombre.toUpperCase() ?? 'USUARIO'}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 36,
                  fontWeight: FontWeight.bold, height: 1.2)),
          const Spacer(),
          // Botones de acción: notificaciones (con badge) y menú
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              GestureDetector(
                onTap: _abrirNotificaciones,
                child: Stack(children: [
                  const Icon(Icons.notifications, color: Colors.white70, size: 44),
                  // Badge rojo con el número de notificaciones no leídas
                  if (noLeidas > 0)
                    Positioned(top: 0, right: 0,
                        child: Container(width: 18, height: 18,
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Center(child: Text('$noLeidas',
                                style: const TextStyle(color: Colors.white,
                                    fontSize: 11, fontWeight: FontWeight.bold))))),
                ]),
              ),
              // Botón circular con "+" para abrir el menú
              GestureDetector(
                onTap: _abrirMenu,
                child: Container(width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 1.5)),
                    child: const Icon(Icons.add, color: Colors.white, size: 32)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
