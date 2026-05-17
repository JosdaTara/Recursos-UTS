import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/models/prestamo.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'package:flutter_recursos_uts/widgets/glass_card.dart';
import 'package:flutter_recursos_uts/widgets/header_with_back.dart';
import 'package:flutter_recursos_uts/widgets/info_row.dart';
import 'package:flutter_recursos_uts/widgets/stat_card.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _seleccionarFoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.bgDark,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(
              color: Colors.white38, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Text('SELECCIONAR FOTO',
              style: TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.camera_alt, color: Colors.white70),
            title: const Text('Cámara',
                style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.white70),
            title: const Text('Galería',
                style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );
    if (source == null) return;
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final usuario = provider.usuarios.isNotEmpty ? provider.usuarios[0] : null;
    final prestamosUsuario = provider.prestamos
        .where((p) => p.usuarioNombre == usuario?.nombre)
        .toList();
    final activos = prestamosUsuario
        .where((p) => p.estado == EstadoPrestamo.activo)
        .length;
    final vencidos = prestamosUsuario
        .where((p) => p.estado == EstadoPrestamo.vencido)
        .length;

    return BackgroundScaffold(
      child: SafeArea(
        child: Column(
          children: [
            const HeaderWithBack(titulo: 'MI PERFIL'),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: const Color(0xFF757575),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 3),
                          ),
                          child: ClipOval(
                            child: _imageFile != null
                                ? Image.file(_imageFile!,
                                    fit: BoxFit.cover,
                                    width: 110,
                                    height: 110)
                                : const Icon(
                                    Icons.person,
                                    size: 65,
                                    color: Colors.white70,
                                  ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _seleccionarFoto,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      usuario?.nombre ?? 'Sin nombre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      usuario?.correo ?? 'sin@correo.com',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        StatCard(label: 'TOTAL', valor: '${prestamosUsuario.length}',
                            color: Colors.white),
                        const SizedBox(width: 10),
                        StatCard(label: 'ACTIVOS', valor: '$activos', color: Colors.greenAccent),
                        const SizedBox(width: 10),
                        StatCard(label: 'VENCIDOS', valor: '$vencidos', color: Colors.redAccent),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DATOS PERSONALES',
                              style: TextStyle(color: Colors.white70,
                                  fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          InfoRow(icono: Icons.person_outline, label: 'Nombre',
                              valor: usuario?.nombre ?? '—'),
                          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
                          const SizedBox(height: 6),
                          InfoRow(icono: Icons.email_outlined, label: 'Correo',
                              valor: usuario?.correo ?? '—'),
                          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
                          const SizedBox(height: 6),
                          InfoRow(icono: Icons.badge_outlined, label: 'Documento',
                              valor: usuario?.documento ?? '—'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('DATOS ACADÉMICOS',
                              style: TextStyle(color: Colors.white70,
                                  fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                          const SizedBox(height: 12),
                          InfoRow(icono: Icons.school_outlined, label: 'Programa',
                              valor: usuario?.programa ?? '—', multilinea: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text(
                          'CERRAR SESIÓN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
