import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/models/prestamo.dart';
import 'package:flutter_recursos_uts/models/usuario.dart';
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
import 'package:flutter_recursos_uts/widgets/stat_card.dart';

class GestionUsuariosScreen extends StatefulWidget {
  const GestionUsuariosScreen({super.key});

  @override
  State<GestionUsuariosScreen> createState() => _GestionUsuariosScreenState();
}

// =============================================================================
// Pantalla de gestión de usuarios del sistema.
// Permite al administrador buscar, filtrar y ver el detalle de usuarios,
// así como activarlos/desactivarlos y consultar su historial de préstamos.
// =============================================================================
class _GestionUsuariosScreenState extends State<GestionUsuariosScreen> {
  // Filtro actual: TODOS, ACTIVOS o INACTIVOS
  String _filtro = 'TODOS';
  final List<String> _filtros = ['TODOS', 'ACTIVOS', 'INACTIVOS'];
  // Controlador y estado para el campo de búsqueda
  final TextEditingController _busquedaController = TextEditingController();
  String _busqueda = '';

  // Filtra la lista de usuarios por estado y/o término de búsqueda
  List<Usuario> _usuariosFiltrados(AppProvider provider) {
    var lista = provider.usuarios.toList();
    if (_filtro == 'ACTIVOS') {
      lista = lista.where((u) => u.activo).toList();
    } else if (_filtro == 'INACTIVOS') {
      lista = lista.where((u) => !u.activo).toList();
    }
    if (_busqueda.isNotEmpty) {
      lista = lista.where((u) {
        final q = _busqueda.toLowerCase();
        return u.nombre.toLowerCase().contains(q) ||
            u.correo.toLowerCase().contains(q) ||
            u.documento.toLowerCase().contains(q);
      }).toList();
    }
    return lista;
  }

  // Retorna un color según el estado del préstamo
  Color _colorEstado(String estado) {
    switch (estado) {
      case 'ACTIVO':
        return Colors.greenAccent;
      case 'DEVUELTO':
        return Colors.white70;
      case 'VENCIDO':
        return Colors.redAccent;
      default:
        return Colors.white70;
    }
  }

  // Muestra el detalle completo del usuario: datos, estadísticas e historial
  void _mostrarDetalle(Usuario u, int index, AppProvider provider) {
    final historial = provider.prestamos
        .where((p) => p.usuarioNombre == u.nombre)
        .toList();
    final devueltos =
        historial.where((p) => p.estado == EstadoPrestamo.devuelto).length;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.white38,
                        borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 20),
                Container(width: 80, height: 80,
                    decoration: const BoxDecoration(color: Color(0xFF757575),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.person, size: 48,
                        color: Colors.white70)),
                const SizedBox(height: 12),
                Text(u.nombre, style: const TextStyle(color: Colors.white,
                    fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                EstadoBadge(
                  texto: u.activo ? 'ACTIVO' : 'INACTIVO',
                  color: u.activo ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 12,
                ),
                const SizedBox(height: 20),
                SectionDivider(titulo: 'DATOS PERSONALES'),
                const SizedBox(height: 8),
                InfoRow(icono: Icons.email_outlined, label: 'Correo', valor: u.correo),
                InfoRow(icono: Icons.badge_outlined, label: 'Documento', valor: u.documento),
                InfoRow(icono: Icons.school_outlined, label: 'Programa', valor: u.programa),
                const SizedBox(height: 12),
                SectionDivider(titulo: 'ESTADÍSTICAS'),
                const SizedBox(height: 12),
                Row(children: [
                  StatCard(label: 'TOTAL', valor: '${historial.length}', color: Colors.white),
                  const SizedBox(width: 8),
                  StatCard(label: 'DEVUELTOS', valor: '$devueltos', color: Colors.greenAccent),
                ]),
                const SizedBox(height: 16),
                SectionDivider(titulo: 'HISTORIAL DE PRÉSTAMOS'),
                const SizedBox(height: 12),
                ...historial.map((h) {
                  return GlassCard(
                    padding: const EdgeInsets.all(12),
                    borderRadius: 12,
                    borderOpacity: 0.2,
                    child: Row(children: [
                      Container(width: 40, height: 40,
                          decoration: const BoxDecoration(color: Colors.white,
                              shape: BoxShape.circle),
child: Icon(getIcon(provider.iconoPorRecurso(h.recursoNombre)), size: 20,
    color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(h.recursoNombre, style: AppStyles.whiteBold13),
                        Text(h.fechaPrestamoStr, style: AppStyles.white54_11),
                      ])),
                      EstadoBadge(
                        texto: h.estado.name.toUpperCase(),
                        color: _colorEstado(h.estado.name.toUpperCase()),
                        fontSize: 10,
                      ),
                    ]),
                  );
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (u.activo) {
                        final activos = provider.prestamos
                            .where((p) => p.usuarioNombre == u.nombre
                                && p.estado == EstadoPrestamo.activo)
                            .toList();
                        if (activos.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              backgroundColor: AppColors.bgDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              title: const Text('NO SE PUEDE DESACTIVAR',
                                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                              content: Text('El usuario tiene ${activos.length} préstamo${activos.length > 1 ? 's' : ''} activo${activos.length > 1 ? 's' : ''}. Debe devolverlo${activos.length > 1 ? 's' : ''} antes de desactivar la cuenta.',
                                  style: const TextStyle(color: Colors.white70)),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('ENTENDIDO', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                      }
                      provider.toggleUsuarioActivo(index);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(u.activo
                              ? 'Usuario desactivado'
                              : 'Usuario activado'),
                          backgroundColor: u.activo
                              ? Colors.red
                              : AppColors.primary),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: u.activo
                        ? Colors.red
                        : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(), elevation: 0),
                    icon: Icon(u.activo ? Icons.block : Icons.check_circle,
                        size: 18),
                    label: Text(u.activo ? 'DESACTIVAR USUARIO'
                        : 'ACTIVAR USUARIO',
                        style: const TextStyle(fontWeight: FontWeight.bold,
                            letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 8),
              ]),
            );
          },
        );
      },
    );
  }

  @override
  // Construye la interfaz con búsqueda, filtros y lista de usuarios
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filtrados = _usuariosFiltrados(provider);

    // Fondo con header, campo de búsqueda y filtros
    return BackgroundScaffold(
      child: SafeArea(
        child: Column(children: [
          const HeaderWithBack(titulo: 'GESTIÓN DE USUARIOS'),
          const SizedBox(height: 16),
          // Campo de búsqueda por nombre, correo o documento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _busquedaController,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _busqueda = v),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, correo o documento...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search,
                    color: Colors.white54, size: 20),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close,
                        color: Colors.white54, size: 18),
                        onPressed: () {
                          setState(() {
                            _busqueda = '';
                            _busquedaController.clear();
                          });
                        })
                    : null,
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.15),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilterChipRow(
            filtros: _filtros, seleccionado: _filtro,
            onChanged: (f) => setState(() => _filtro = f)),
          const SizedBox(height: 16),
          // Lista de usuarios filtrados o mensaje vacío
          Expanded(
            child: filtrados.isEmpty
                ? const Center(child: Text('No se encontraron usuarios',
                    style: TextStyle(color: Colors.white70, fontSize: 15)))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtrados.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final u = filtrados[i];
                      final userIndex = provider.usuarios.indexOf(u);
                      final prestamosUser = provider.prestamos
                          .where((p) => p.usuarioNombre == u.nombre)
                          .toList();
                      final vencidos = prestamosUser
                          .where((p) => p.estado == EstadoPrestamo.vencido)
                          .length;
                      return GestureDetector(
                        onTap: () => _mostrarDetalle(u, userIndex, provider),
                        child: GlassCard(
                          borderOpacity: vencidos > 0 ? 0.5 : 0.3,
                          child: Container(
                            decoration: vencidos > 0
                                ? BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: Colors.redAccent.withValues(alpha: 0.5),
                                        width: 2))
                                : null,
                            child: Row(children: [
                              Container(width: 52, height: 52,
                                  decoration: const BoxDecoration(
                                      color: Color(0xFF757575),
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.person, size: 28,
                                      color: Colors.white70)),
                              const SizedBox(width: 14),
                              Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Row(children: [
                                  Expanded(
                                    child: Text(u.nombre,
                                        style: AppStyles.whiteBold16,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 8),
                                  EstadoBadge(
                                    texto: u.activo ? 'ACTIVO' : 'INACTIVO',
                                    color: u.activo ? Colors.greenAccent : Colors.redAccent,
                                  ),
                                ]),
                                const SizedBox(height: 4),
                                Text(u.correo, style: AppStyles.white70_12),
                                Row(children: [
                                  Text('${prestamosUser.length} préstamos',
                                      style: AppStyles.white54_11),
                                  if (vencidos > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10)),
                                      child: Text('$vencidos vencido${vencidos > 1 ? 's' : ''}',
                                          style: const TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ]),
                              ])),
                              const Icon(Icons.chevron_right,
                                  color: Colors.white54),
                            ]),
                          ),
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
