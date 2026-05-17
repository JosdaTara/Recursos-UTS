// Menú de navegación principal del usuario.
// Muestra botones para acceder a Perfil, Solicitar Préstamo,
// Mis Préstamos y Ver Recursos, más un botón de cierre.

import 'package:flutter/material.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'perfil_screen.dart';
import 'solicitar_prestamo_screen.dart';
import 'mis_prestamos_screen.dart';
import 'recursos_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Contenedor de los botones del menú
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  // Botón para ir a la pantalla de Perfil
                  _buildMenuButton(
                    icon: Icons.person,
                    label: 'PERFIL',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PerfilScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  // Botón para ir a la pantalla de Solicitar Préstamo
                  _buildMenuButton(
                    icon: Icons.download,
                    label: 'SOLICITAR PRÉSTAMO',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SolicitarPrestamoScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  // Botón para ir a la pantalla de Mis Préstamos
                  _buildMenuButton(
                    icon: Icons.assignment,
                    label: 'MIS PRÉSTAMOS',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MisPrestamosScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  // Botón para ir a la pantalla de Ver Recursos
                  _buildMenuButton(
                    icon: Icons.inventory_2,
                    label: 'VER RECURSOS',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const RecursosScreen()));
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Botón de cerrar menú (X) en la esquina inferior derecha
            Padding(
              padding: const EdgeInsets.only(right: 24, bottom: 32),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white54, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construye un botón del menú con icono, texto y acción al presionar
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: Colors.white60, width: 2),
        ),
        child: Row(
          children: [
            // Círculo con el icono del botón
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            // Texto descriptivo del botón
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
