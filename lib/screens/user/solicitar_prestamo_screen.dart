import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/models/solicitud.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'package:flutter_recursos_uts/widgets/glass_card.dart';
import 'package:flutter_recursos_uts/widgets/header_with_back.dart';

// Pantalla para solicitar un préstamo de recursos. Permite seleccionar
// el tipo de recurso, elegir fechas/hora de préstamo y devolución, y
// opcionalmente apartar un equipo de cómputo o agregar accesorios.
class SolicitarPrestamoScreen extends StatefulWidget {
  const SolicitarPrestamoScreen({super.key});

  @override
  State<SolicitarPrestamoScreen> createState() =>
      _SolicitarPrestamoScreenState();
}

class _SolicitarPrestamoScreenState extends State<SolicitarPrestamoScreen> {
  // Recurso seleccionado por el usuario (ej. COMPUTADOR, VIDEO BEAM, etc.)
  String? _recursoSeleccionado;
  // Fecha y hora de inicio del préstamo
  DateTime? _fechaPrestamo;
  TimeOfDay? _horaPrestamo;
  // Fecha y hora de devolución del préstamo
  DateTime? _fechaDevolucion;
  TimeOfDay? _horaDevolucion;
  // Salón y equipo seleccionados (solo para tipo "computador")
  String? _salonSeleccionado;
  String? _equipoSeleccionado;
  // Lista de accesorios adicionales seleccionados (solo para tipo "accesorio")
  final List<String> _accesoriosSeleccionados = [];

  // Catálogo de recursos disponibles para préstamo con su ícono, tipo y accesorios opcionales
  final Map<String, Map<String, dynamic>> _recursos = {
    'COMPUTADOR': {'icono': Icons.computer, 'tipo': 'computador'},
    'VIDEO BEAM': {'icono': Icons.videocam, 'tipo': 'accesorio',
        'accesorios': ['CABLE HDMI', 'CABLE RCA', 'EXTENSIÓN']},
    'PARLANTES': {'icono': Icons.speaker, 'tipo': 'accesorio',
        'accesorios': ['CABLE RCA', 'CABLE USB', 'EXTENSIÓN']},
    'CABLE HDMI': {'icono': Icons.cable, 'tipo': 'simple'},
    'CABLE RCA': {'icono': Icons.settings_input_composite, 'tipo': 'simple'},
    'CABLE USB': {'icono': Icons.usb, 'tipo': 'simple'},
    'EXTENSIÓN': {'icono': Icons.electrical_services, 'tipo': 'simple'},
  };

  // Abre un DatePicker para seleccionar la fecha de préstamo o devolución
  Future<void> _seleccionarFecha(bool esPrestamo) async {
    final picked = await showDatePicker(
      context: context, initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary)),
          child: child!));
    if (picked != null) {
      setState(() {
        if (esPrestamo) {
          _fechaPrestamo = picked;
        } else {
          _fechaDevolucion = picked;
        }
      });
    }
  }

  // Abre un TimePicker para seleccionar la hora de préstamo o devolución;
  // valida que la hora no sea anterior a la hora actual
  Future<void> _seleccionarHora(bool esPrestamo) async {
    final fecha = esPrestamo ? _fechaPrestamo : _fechaDevolucion;
    final picked = await showTimePicker(
      context: context, initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary)),
          child: child!));
    if (picked != null) {
      final now = DateTime.now();
      final selected = DateTime(
        fecha?.year ?? now.year,
        fecha?.month ?? now.month,
        fecha?.day ?? now.day,
        picked.hour,
        picked.minute,
      );
      if (selected.isBefore(now)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La hora no puede ser anterior a la actual'),
            backgroundColor: Colors.red),
        );
        return;
      }
      setState(() {
        if (esPrestamo) {
          _horaPrestamo = picked;
        } else {
          _horaDevolucion = picked;
        }
      });
    }
  }

  // Formatea una fecha para mostrar en la UI (dd/mm/aaaa)
  String _fmtFecha(DateTime? d) => d == null ? 'dd/mm/aaaa' :
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  // Formatea una hora para mostrar en la UI (formato 12h con AM/PM)
  String _fmtHora(TimeOfDay? t) {
    if (t == null) return '--:--';
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    return '$h:${t.minute.toString().padLeft(2, '0')} ${t.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  // Construye una tarjeta individual para cada recurso en la cuadrícula de selección
  Widget _buildTarjetaRecurso(String nombre) {
    final data = _recursos[nombre]!;
    final sel = _recursoSeleccionado == nombre;
    return GestureDetector(
      onTap: () => setState(() {
        _recursoSeleccionado = nombre;
        _accesoriosSeleccionados.clear();
        _salonSeleccionado = null;
        _equipoSeleccionado = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: sel ? Colors.white : Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: sel ? AppColors.primary : Colors.white54,
              width: sel ? 2.5 : 1.5)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(data['icono'] as IconData, size: 30,
              color: sel ? AppColors.primary : Colors.white),
          const SizedBox(height: 6),
          Text(nombre, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                  color: sel ? AppColors.primary : Colors.white)),
        ]),
      ),
    );
  }

  // Construye la sección para apartar un equipo de cómputo (salón + equipo)
  Widget _buildSeccionComputador(AppProvider provider) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('APARTAR EQUIPO', style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: _salonSeleccionado,
            hint: const Text('Seleccionar salón',
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
            dropdownColor: Colors.white,
            onChanged: (v) => setState(() {
              _salonSeleccionado = v; _equipoSeleccionado = null;
            }),
            items: provider.salonesDropdown.keys.map((s) =>
                DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13,
                    color: Colors.black87)))).toList(),
          )),
        ),
        if (_salonSeleccionado != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: _equipoSeleccionado,
              hint: const Text('Seleccionar equipo',
                  style: TextStyle(fontSize: 13, color: Colors.black54)),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
              dropdownColor: Colors.white,
              onChanged: (v) => setState(() => _equipoSeleccionado = v),
              items: provider.salonesDropdown[_salonSeleccionado]!.map((e) =>
                  DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13,
                      color: Colors.black87)))).toList(),
            )),
          ),
        ],
      ]),
    );
  }

  // Construye la sección de accesorios opcionales con checkboxes seleccionables
  Widget _buildSeccionAccesorios() {
    final accs = _recursos[_recursoSeleccionado]!['accesorios'] as List<String>;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 16),
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('ACCESORIOS OPCIONALES', style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)),
        const SizedBox(height: 12),
        ...accs.map((acc) {
          final sel = _accesoriosSeleccionados.contains(acc);
          return GestureDetector(
            onTap: () => setState(() => sel
                ? _accesoriosSeleccionados.remove(acc)
                : _accesoriosSeleccionados.add(acc)),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: sel ? Colors.white : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: sel ? AppColors.primary : Colors.white54,
                    width: sel ? 2 : 1)),
              child: Row(children: [
                Icon(sel ? Icons.check_box : Icons.check_box_outline_blank,
                    color: sel ? AppColors.primary : Colors.white70, size: 20),
                const SizedBox(width: 10),
                Text(acc, style: TextStyle(
                    color: sel ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.bold, fontSize: 13)),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  // Muestra un diálogo de confirmación con la información completa del préstamo
  void _mostrarConfirmacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.info_outline, color: Colors.white70, size: 22),
          SizedBox(width: 8),
          Text('CONFIRMAR PRÉSTAMO',
              style: TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ]),
        content: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, children: [
            _detalle(Icons.inventory_2, 'Recurso', _recursoSeleccionado!),
            const Divider(color: Colors.white24, height: 16),
            _detalle(Icons.login, 'Fecha préstamo',
                '${_fmtFecha(_fechaPrestamo)}  ${_fmtHora(_horaPrestamo)}'),
            const Divider(color: Colors.white24, height: 16),
            _detalle(Icons.logout, 'Fecha devolución',
                '${_fmtFecha(_fechaDevolucion)}  ${_fmtHora(_horaDevolucion)}'),
            if (_salonSeleccionado != null && _equipoSeleccionado != null) ...[
              const Divider(color: Colors.white24, height: 16),
              _detalle(Icons.meeting_room, 'Salón', _salonSeleccionado!),
              const Divider(color: Colors.white24, height: 16),
              _detalle(Icons.computer, 'Equipo', _equipoSeleccionado!),
            ],
            if (_accesoriosSeleccionados.isNotEmpty) ...[
              const Divider(color: Colors.white24, height: 16),
              _detalle(Icons.construction, 'Accesorios',
                  _accesoriosSeleccionados.join(', ')),
            ],
          ]),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('CANCELAR',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              final provider = context.read<AppProvider>();
              final tipo = _recursos[_recursoSeleccionado]!['tipo'] as String;
              final usuario = provider.usuarios.isNotEmpty
                  ? provider.usuarios[0] : null;
              final solicitud = Solicitud(
                id: 'sol_${DateTime.now().millisecondsSinceEpoch}',
                usuarioNombre: usuario?.nombre ?? 'Usuario',
                documento: usuario?.documento ?? '—',
                programa: usuario?.programa ?? '—',
                recursoNombre: _recursoSeleccionado!,
                recursoIcono: _recursos[_recursoSeleccionado]!['icono'] as IconData,
                accesorios: tipo == 'accesorio'
                    ? List.from(_accesoriosSeleccionados)
                    : tipo == 'computador'
                        ? []
                        : [],
                salon: tipo == 'computador' ? _salonSeleccionado : null,
                equipo: tipo == 'computador' ? _equipoSeleccionado : null,
                fechaPrestamo: DateTime(
                  _fechaPrestamo!.year, _fechaPrestamo!.month, _fechaPrestamo!.day,
                  _horaPrestamo!.hour, _horaPrestamo!.minute,
                ),
                fechaDevolucion: DateTime(
                  _fechaDevolucion!.year, _fechaDevolucion!.month, _fechaDevolucion!.day,
                  _horaDevolucion!.hour, _horaDevolucion!.minute,
                ),
                fechaSolicitud: DateTime.now(),
                estado: EstadoSolicitud.pendiente,
              );
              provider.agregarSolicitud(solicitud);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('¡Solicitud enviada!'),
                      backgroundColor: AppColors.primary));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              shadowColor: Colors.green.withValues(alpha: 0.4)),
            icon: const Icon(Icons.check_circle, size: 20),
            label: const Text('CONFIRMAR',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _detalle(IconData icono, String label, String valor) {
    return Row(children: [
      Icon(icono, color: AppColors.primaryLight, size: 20),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(valor, style: const TextStyle(color: Colors.white, fontSize: 14,
            fontWeight: FontWeight.bold)),
      ]),
    ]);
  }

  // Construye las secciones de fecha/hora de préstamo y devolución
  Widget _buildFechasHoras() {
    return Column(children: [
      GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        borderRadius: 16, padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('FECHA Y HORA DE PRÉSTAMO', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold,
              fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => _seleccionarFecha(true),
              child: _fechaBox(_fmtFecha(_fechaPrestamo), Icons.calendar_today))),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => _seleccionarHora(true),
              child: _fechaBox(_fmtHora(_horaPrestamo), Icons.access_time))),
          ]),
        ]),
      ),
      GlassCard(
        margin: const EdgeInsets.only(bottom: 16),
        borderRadius: 16, padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('FECHA Y HORA DE DEVOLUCIÓN', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold,
              fontSize: 12, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => _seleccionarFecha(false),
              child: _fechaBox(_fmtFecha(_fechaDevolucion), Icons.calendar_today))),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => _seleccionarHora(false),
              child: _fechaBox(_fmtHora(_horaDevolucion), Icons.access_time))),
          ]),
        ]),
      ),
    ]);
  }

  // Construye un cuadro con ícono y texto para mostrar fecha u hora seleccionada
  Widget _fechaBox(String texto, IconData icono) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Icon(icono, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ]),
    );
  }

  // Valida que la fecha/hora de devolución sea posterior a la de préstamo
  bool _validarFechas() {
    if (_fechaPrestamo == null || _horaPrestamo == null ||
        _fechaDevolucion == null || _horaDevolucion == null) {
      return false;
    }
    final inicio = DateTime(
      _fechaPrestamo!.year, _fechaPrestamo!.month, _fechaPrestamo!.day,
      _horaPrestamo!.hour, _horaPrestamo!.minute,
    );
    final fin = DateTime(
      _fechaDevolucion!.year, _fechaDevolucion!.month, _fechaDevolucion!.day,
      _horaDevolucion!.hour, _horaDevolucion!.minute,
    );
    if (fin.isBefore(inicio) || fin.isAtSameMomentAs(inicio)) {
      return false;
    }
    return true;
  }

  // Verifica si una fecha/hora combinada ya pasó respecto al momento actual
  bool _tieneFechaPasada(DateTime? fecha, TimeOfDay? hora) {
    if (fecha == null || hora == null) return false;
    final selected = DateTime(
      fecha.year, fecha.month, fecha.day, hora.hour, hora.minute,
    );
    return selected.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el provider y el tipo del recurso seleccionado (computador, accesorio, simple)
    final provider = context.read<AppProvider>();
    final tipo = _recursoSeleccionado != null
        ? _recursos[_recursoSeleccionado]!['tipo'] as String
        : null;

    return BackgroundScaffold(
      child: SafeArea(
        child: Column(children: [
          const HeaderWithBack(titulo: 'SOLICITAR PRÉSTAMO'),
          const SizedBox(height: 20),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Cuadrícula de recursos disponibles para seleccionar
              const Text('SELECCIONA UN RECURSO', style: TextStyle(
                  color: Colors.white70, fontSize: 11,
                  fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 10),
              // Cuadrícula de 4 columnas con las tarjetas de cada recurso disponible
              GridView.count(
                crossAxisCount: 4, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.85,
                children: _recursos.keys.map(
                    (r) => _buildTarjetaRecurso(r)).toList(),
              ),
              const SizedBox(height: 20),
              // Secciones dinámicas según el tipo de recurso seleccionado
              if (tipo == 'computador') _buildSeccionComputador(provider),
              if (tipo == 'accesorio') _buildSeccionAccesorios(),
              // Fechas y botón de envío solo si hay un recurso seleccionado
              if (_recursoSeleccionado != null) _buildFechasHoras(),
              if (_recursoSeleccionado != null)
                SizedBox(width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Validaciones antes de enviar la solicitud
                        if (_fechaPrestamo == null ||
                            _horaPrestamo == null ||
                            _fechaDevolucion == null ||
                            _horaDevolucion == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  'Completa las fechas y horas')));
                          return;
                        }
                        if (_tieneFechaPasada(_fechaPrestamo, _horaPrestamo)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'La fecha/hora de préstamo ya pasó'),
                                  backgroundColor: Colors.red));
                          return;
                        }
                        if (!_validarFechas()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'La devolución debe ser después del préstamo'),
                                  backgroundColor: Colors.red));
                          return;
                        }
                        if (tipo == 'computador' &&
                            (_salonSeleccionado == null ||
                                _equipoSeleccionado == null)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text(
                                  'Selecciona el salón y equipo')));
                          return;
                        }
                        _mostrarConfirmacion(context);
                      },
                      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.bgDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: const StadiumBorder()),
                      child: const Text('ENVIAR SOLICITUD', style: TextStyle(
                          fontWeight: FontWeight.bold, letterSpacing: 1.0)))),
              const SizedBox(height: 24),
            ]),
          )),
        ]),
      ),
    );
  }
}
