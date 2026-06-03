import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/models/prestamo.dart';
import 'package:flutter_recursos_uts/models/recurso.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/utils/icon_utils.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'package:flutter_recursos_uts/widgets/header_with_back.dart';
import 'package:flutter_recursos_uts/widgets/info_row.dart';

class EscanerScreen extends StatefulWidget {
  const EscanerScreen({super.key});

  @override
  State<EscanerScreen> createState() => _EscanerScreenState();
}

// =============================================================================
// Pantalla de escaneo de códigos de barras.
// Permite al administrador escanear el código de barras de un recurso
// para consultar su estado y registrar devoluciones de préstamos.
// =============================================================================
class _EscanerScreenState extends State<EscanerScreen> {
  // Controlador de la cámara/scanner
  MobileScannerController? _controller;
  // Bandera para evitar múltiples escaneos simultáneos
  bool _procesando = false;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // Maneja la detección de un código de barras: busca el recurso y préstamo activo
  void _onDetect(BarcodeCapture capture) {
    if (_procesando) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    _procesando = true;
    _controller?.stop();
    final codigo = barcode.rawValue!;
    final provider = context.read<AppProvider>();
    final recurso = provider.recursoPorCodigo(codigo);
    final prestamo =
        recurso != null ? provider.prestamoActivoPorRecurso(recurso.nombre) : null;

    if (!mounted) return;
    _mostrarResultado(codigo, recurso, prestamo);
  }

  // Muestra un BottomSheet con el resultado del escaneo e información del recurso/préstamo
  void _mostrarResultado(String codigo, Recurso? recurso, Prestamo? prestamo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.white38, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Icon(
            recurso == null
                ? Icons.error_outline
                : prestamo != null
                    ? Icons.swap_horiz
                    : Icons.check_circle,
            color: recurso == null
                ? Colors.redAccent
                : prestamo != null
                    ? Colors.orange
                    : Colors.greenAccent,
            size: 64,
          ),
          const SizedBox(height: 12),
          Text(
            recurso == null
                ? 'NO ENCONTRADO'
                : prestamo != null
                    ? 'PRÉSTAMO ACTIVO'
                    : 'SIN PRÉSTAMO ACTIVO',
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('Código: $codigo',
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
          ),
          if (recurso != null) ...[
            const SizedBox(height: 16),
            Container(width: 65, height: 65,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
                child: Icon(getIcon(recurso.icono), size: 34,
                    color: AppColors.primary)),
            const SizedBox(height: 8),
            Text(recurso.nombre, style: const TextStyle(color: Colors.white,
                fontSize: 20, fontWeight: FontWeight.bold)),
          ],
          if (prestamo != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(children: [
                InfoRow(icono: Icons.person_outline, label: 'Usuario',
                    valor: prestamo.usuarioNombre),
                InfoRow(icono: Icons.login, label: 'Inicio',
                    valor: prestamo.fechaPrestamoStr),
                InfoRow(icono: Icons.logout, label: 'Tope devolución',
                    valor: prestamo.fechaDevolucionStr),
                if (prestamo.accesorios.isNotEmpty)
                  InfoRow(icono: Icons.construction, label: 'Accesorios',
                      valor: prestamo.accesorios.join(', ')),
              ]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final provider = context.read<AppProvider>();
                  await provider.devolverPrestamo(prestamo);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Devolución registrada correctamente'),
                      backgroundColor: Colors.green),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const StadiumBorder()),
                icon: const Icon(Icons.check_circle, size: 20),
                label: const Text('REGISTRAR DEVOLUCIÓN',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          if (recurso != null && prestamo == null) ...[
            const SizedBox(height: 16),
            Text('${recurso.disponible} de ${recurso.total} disponibles',
                style: TextStyle(
                    color: recurso.disponible > 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            if (recurso.accesoriosIncluidos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('ACCESORIOS INCLUIDOS:',
                  style: const TextStyle(color: Colors.white70, fontSize: 11,
                      fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8,
                  children: recurso.accesoriosIncluidos.map((acc) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white38)),
                    child: Text(acc, style: const TextStyle(color: Colors.white,
                        fontSize: 12, fontWeight: FontWeight.bold)),
                  )).toList()),
            ],
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _procesando = false;
                  _controller?.start();
                });
              },
              child: const Text('ESCANEAR OTRO',
                  style: TextStyle(color: Colors.white70,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          _procesando = false;
          _controller?.start();
        });
      }
    });
  }

  @override
  // Construye la interfaz con la cámara/scanner y las instrucciones
  Widget build(BuildContext context) {
    // Fondo con header, visor de cámara y marco guía para el escaneo
    return BackgroundScaffold(
      child: SafeArea(
        child: Column(children: [
          const HeaderWithBack(titulo: 'ESCANEAR CÓDIGO'),
          // Visor de la cámara con un recuadro guía superpuesto
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(children: [
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.white, width: 3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
          // Texto de instrucción para el usuario
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text('Apunta el código de barras al centro de la cámara',
                textAlign: TextAlign.center,
                style: AppStyles.white70_12),
          ),
        ]),
      ),
    );
  }
}