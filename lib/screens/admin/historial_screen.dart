import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

// =============================================================================
// Pantalla de historial de préstamos.
// Muestra todos los préstamos registrados con opciones de búsqueda,
// filtros por estado, estadísticas resumidas y el recurso más prestado.
// =============================================================================
class _HistorialScreenState extends State<HistorialScreen> {
  // Filtro actual: TODOS, ACTIVOS, DEVUELTOS o VENCIDOS
  String _filtro = 'TODOS';
  final List<String> _filtros = ['TODOS', 'ACTIVOS', 'DEVUELTOS', 'VENCIDOS'];
  // Controlador y estado para la búsqueda por usuario o recurso
  final TextEditingController _busquedaController = TextEditingController();
  String _busqueda = '';

  // Filtra los préstamos por estado y/o término de búsqueda
  List<Map<String, dynamic>> _filtrado(AppProvider provider) {
    var lista = provider.prestamosParaHistorial();
    if (_filtro != 'TODOS') {
      final estadoBuscado = _filtro;
      lista = lista.where((h) {
        if (estadoBuscado == 'ACTIVOS') return h['estado'] == 'ACTIVO';
        if (estadoBuscado == 'DEVUELTOS') return h['estado'] == 'DEVUELTO';
        return h['estado'] == 'VENCIDO';
      }).toList();
    }
    if (_busqueda.isNotEmpty) {
      lista = lista.where((h) {
        final usuario = (h['usuario'] as String).toLowerCase();
        final recurso = (h['recurso'] as String).toLowerCase();
        return usuario.contains(_busqueda.toLowerCase()) ||
            recurso.contains(_busqueda.toLowerCase());
      }).toList();
    }
    return lista;
  }

  // Obtiene el recurso con mayor cantidad de préstamos registrados
  Map<String, dynamic> _recursoMasPrestado(AppProvider provider) {
    return provider.recursoMasPrestado();
  }

  // Retorna un color según el estado del préstamo en el historial
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

  // Muestra un BottomSheet con el detalle completo del préstamo histórico
  void _mostrarDetalle(Map<String, dynamic> h) {
    final accesorios = h['accesorios'] as List;
    final String estado = h['estado'] as String;
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
                child: Icon(getIcon(h['icono'] as String), size: 34,
                    color: AppColors.primary)),
            const SizedBox(height: 12),
            Text(h['recurso'] as String, style: const TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            EstadoBadge(texto: estado, color: _colorEstado(estado), fontSize: 12),
            const SizedBox(height: 20),
            SectionDivider(titulo: 'USUARIO'),
            const SizedBox(height: 8),
            InfoRow(icono: Icons.person_outline, label: 'Nombre', valor: h['usuario'] as String),
            const SizedBox(height: 12),
            SectionDivider(titulo: 'PRÉSTAMO'),
            const SizedBox(height: 8),
            if (h['salon'] != null)
              InfoRow(icono: Icons.meeting_room, label: 'Salón',
                  valor: '${h['salon']} - ${h['equipo']}'),
            InfoRow(icono: Icons.login, label: 'Fecha préstamo',
                valor: '${h['fechaPrestamo']}  ${h['horaPrestamo']}'),
            InfoRow(icono: Icons.logout, label: 'Fecha devolución',
                valor: '${h['fechaDevolucion']}  ${h['horaDevolucion']}'),
            if (accesorios.isNotEmpty) ...[
              const SizedBox(height: 12),
              SectionDivider(titulo: 'ACCESORIOS'),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                  children: accesorios.map((acc) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white38)),
                    child: Text(acc as String, style: const TextStyle(
                        color: Colors.white, fontSize: 12,
                        fontWeight: FontWeight.bold)),
                  )).toList()),
            ],
            const SizedBox(height: 16),
          ]),
        );
      },
    );
  }

  @override
  // Construye la interfaz con estadísticas, recurso más prestado, filtros y lista
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filtrado = _filtrado(provider);
    final mas = _recursoMasPrestado(provider);
    final historial = provider.prestamosParaHistorial();
    final activos = historial.where((h) => h['estado'] == 'ACTIVO').length;
    final devueltos = historial.where((h) => h['estado'] == 'DEVUELTO').length;
    final vencidos = historial.where((h) => h['estado'] == 'VENCIDO').length;

    // Fondo con header, campo de búsqueda, tarjetas de estadísticas y filtros
    return BackgroundScaffold(
      child: SafeArea(
        child: Column(children: [
          const HeaderWithBack(titulo: 'HISTORIAL'),
          const SizedBox(height: 16),
          // Campo de búsqueda por usuario o recurso
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _busquedaController,
              style: const TextStyle(color: Colors.white),
              onChanged: (v) => setState(() => _busqueda = v),
              decoration: InputDecoration(
                hintText: 'Buscar por usuario o recurso...',
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
          // Tarjetas resumen con conteo de activos, devueltos y vencidos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              StatCard(label: 'ACTIVOS', valor: '$activos', color: Colors.greenAccent),
              const SizedBox(width: 10),
              StatCard(label: 'DEVUELTOS', valor: '$devueltos', color: Colors.white70),
              const SizedBox(width: 10),
              StatCard(label: 'VENCIDOS', valor: '$vencidos', color: Colors.redAccent),
            ]),
          ),
          const SizedBox(height: 16),
          // Tarjeta del recurso más prestado con barra de progreso
          GlassCard(
            borderRadius: 16,
            child: Row(children: [
              Container(width: 44, height: 44,
                  decoration: const BoxDecoration(color: Colors.white,
                      shape: BoxShape.circle),
                  child: Icon(getIcon(mas['icono'] as String),
                      color: AppColors.primary, size: 22)),
              const SizedBox(width: 12),
              Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('MÁS PRESTADO', style: TextStyle(
                    color: Colors.white54, fontSize: 10,
                    fontWeight: FontWeight.bold, letterSpacing: 1)),
                Text(mas['nombre'] as String, style: const TextStyle(
                    color: Colors.white, fontSize: 14,
                    fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mas['porcentaje'] as double,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.greenAccent),
                      minHeight: 5)),
              ])),
              const SizedBox(width: 12),
              Text('${mas['cantidad']} veces', style: const TextStyle(
                  color: Colors.greenAccent, fontSize: 13,
                  fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 16),
          FilterChipRow(
            filtros: _filtros, seleccionado: _filtro,
            onChanged: (f) => setState(() => _filtro = f)),
          const SizedBox(height: 16),
          // Lista de registros filtrados o mensaje vacío
          Expanded(
            child: filtrado.isEmpty
                ? Center(child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search_off, color: Colors.white38, size: 60),
                      SizedBox(height: 12),
                      Text('No se encontraron registros',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 15)),
                    ]))
                : RefreshIndicator(
                    onRefresh: () => context.read<AppProvider>().refrescarDatos(),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtrado.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                      final h = filtrado[i];
                      final String estado = h['estado'] as String;
                      final List accesorios = h['accesorios'] as List;
                      return GestureDetector(
                        onTap: () => _mostrarDetalle(h),
                        child: GlassCard(
                          child: Row(children: [
                            Container(width: 52, height: 52,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: Icon(getIcon(h['icono'] as String), size: 26,
                                    color: AppColors.primary)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(h['recurso'] as String,
                                        style: AppStyles.whiteBold16),
                                    EstadoBadge(
                                        texto: estado,
                                        color: _colorEstado(estado)),
                                  ]),
                              const SizedBox(height: 4),
                              Text(h['usuario'] as String, style: AppStyles.white70_12),
                              Text('${h['fechaPrestamo']}  ${h['horaPrestamo']}',
                                  style: AppStyles.white54_11),
                              if (accesorios.isNotEmpty)
                                Text('+ ${accesorios.join(', ')}',
                                    style: AppStyles.white54_11,
                                    overflow: TextOverflow.ellipsis),
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
