import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/models/recurso.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'package:flutter_recursos_uts/widgets/glass_card.dart';
import 'package:flutter_recursos_uts/widgets/header_with_back.dart';

class GestionRecursosScreen extends StatefulWidget {
  const GestionRecursosScreen({super.key});

  @override
  State<GestionRecursosScreen> createState() => _GestionRecursosScreenState();
}

// =============================================================================
// Pantalla de gestión de recursos (inventario).
// Permite al administrador crear, editar y eliminar recursos,
// así como visualizar su disponibilidad mediante indicadores visuales.
// =============================================================================
class _GestionRecursosScreenState extends State<GestionRecursosScreen> {
  // Retorna un color según la proporción de disponibilidad del recurso
  Color _colorDisponibilidad(int disponible, int total) {
    final double porcentaje = total > 0 ? disponible / total : 0;
    if (porcentaje <= 0.3) return Colors.red;
    if (porcentaje <= 0.6) return Colors.orange;
    return Colors.greenAccent;
  }

  // Muestra un formulario en BottomSheet para crear o editar un recurso
  void _mostrarFormulario({Recurso? recurso, int? index}) {
    final nombreController =
        TextEditingController(text: recurso?.nombre ?? '');
    final totalController =
        TextEditingController(text: recurso?.total.toString() ?? '');
    final disponibleController =
        TextEditingController(text: recurso?.disponible.toString() ?? '');
    final codigoBarrasController =
        TextEditingController(text: recurso?.codigoBarras ?? '');
    final accesoriosController = TextEditingController(
        text: recurso?.accesoriosIncluidos.join(', ') ?? '');
    final esEdicion = recurso != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white38,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(esEdicion ? 'EDITAR RECURSO' : 'NUEVO RECURSO',
                style: const TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 20),
            _buildCampoForm(controller: nombreController,
                hint: 'Nombre del recurso', icono: Icons.inventory_2),
            const SizedBox(height: 12),
            _buildCampoForm(controller: totalController,
                hint: 'Cantidad total', icono: Icons.numbers,
                teclado: TextInputType.number),
            const SizedBox(height: 12),
            _buildCampoForm(controller: disponibleController,
                hint: 'Cantidad disponible', icono: Icons.check_circle_outline,
                teclado: TextInputType.number),
            const SizedBox(height: 12),
            _buildCampoForm(controller: codigoBarrasController,
                hint: 'Código de barras (ej: VB-001)',
                icono: Icons.qr_code),
            const SizedBox(height: 12),
            _buildCampoForm(controller: accesoriosController,
                hint: 'Accesorios (separados por coma)',
                icono: Icons.construction),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final nombre = nombreController.text.trim();
                  final total = int.tryParse(totalController.text);
                  final disponible = int.tryParse(disponibleController.text);
                  if (nombre.isEmpty || total == null || disponible == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Completa todos los campos')));
                    return;
                  }
                  if (disponible > total) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text(
                          'La disponibilidad no puede ser mayor al total'),
                          backgroundColor: Colors.red));
                    return;
                  }
                  final provider = context.read<AppProvider>();
                  final r = Recurso(
                    nombre: nombre.toUpperCase(),
                    icono: Icons.inventory_2,
                    total: total,
                    disponible: disponible,
                    codigoBarras: codigoBarrasController.text.trim().isEmpty
                        ? null
                        : codigoBarrasController.text.trim(),
                    accesoriosIncluidos: accesoriosController.text
                        .split(',')
                        .map((e) => e.trim().toUpperCase())
                        .where((e) => e.isNotEmpty)
                        .toList(),
                  );
                  if (esEdicion && index != null) {
                    provider.editarRecurso(index, r);
                  } else {
                    provider.agregarRecurso(r);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(esEdicion
                          ? 'Recurso actualizado'
                          : 'Recurso agregado'),
                      backgroundColor: AppColors.primary),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder(), elevation: 0),
                child: Text(esEdicion ? 'GUARDAR CAMBIOS' : 'AGREGAR RECURSO',
                    style: const TextStyle(fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ),
            ),
          ]),
        ),
        );
      },
    );
  }

  // Muestra un diálogo de confirmación antes de eliminar un recurso
  void _confirmarEliminar(int index, AppProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar recurso?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          '¿Estás seguro de eliminar ${provider.recursos[index].nombre}?',
          style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR',
                  style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              provider.eliminarRecurso(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Recurso eliminado'),
                    backgroundColor: Colors.red));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, shape: const StadiumBorder()),
            child: const Text('ELIMINAR', style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Construye un campo de texto estilizado para el formulario de recurso
  Widget _buildCampoForm({
    required TextEditingController controller,
    required String hint,
    required IconData icono,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: teclado,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icono, color: Colors.white70, size: 20),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
      ),
    );
  }

  @override
  // Construye la interfaz con header, botón de agregar y lista de recursos
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    // Fondo con header y botón flotante para agregar nuevo recurso
    return BackgroundScaffold(
      child: SafeArea(
        child: Column(children: [
          HeaderWithBack(
            titulo: 'GESTIÓN DE RECURSOS',
            trailing: GestureDetector(
              onTap: () => _mostrarFormulario(),
              child: Container(width: 38, height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 1.5)),
                  child: const Icon(Icons.add,
                      color: Colors.white, size: 22)),
            ),
          ),
          const SizedBox(height: 20),
          // Lista de recursos con barra de progreso y botones editar/eliminar
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: provider.recursos.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final r = provider.recursos[i];
                return GlassCard(
                  child: Row(children: [
                    Container(width: 52, height: 52,
                        decoration: const BoxDecoration(color: Colors.white,
                            shape: BoxShape.circle),
                        child: Icon(r.icono, size: 26,
                            color: AppColors.primary)),
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
                        Text(' de ${r.total}', style: AppStyles.white54_11),
                      ]),
                      const SizedBox(height: 6),
                      ClipRRect(borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: r.porcentajeDisponible,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _colorDisponibilidad(r.disponible, r.total)),
                            minHeight: 5)),
                    ])),
                    const SizedBox(width: 8),
                    Column(children: [
                      GestureDetector(
                        onTap: () => _mostrarFormulario(recurso: r, index: i),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => _confirmarEliminar(i, provider),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.delete,
                              color: Colors.white, size: 16),
                        ),
                      ),
                    ]),
                  ]),
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
