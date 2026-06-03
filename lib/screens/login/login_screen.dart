// Pantalla de inicio de sesión donde el usuario ingresa su correo y contraseña.
// Valida las credenciales contra credenciales predeterminadas y redirige
// a la pantalla de usuario normal o de administrador según corresponda.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_recursos_uts/providers/app_provider.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'package:flutter_recursos_uts/widgets/glass_card.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // Controladores para los campos de texto
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  // Estado de la UI
  bool _verContrasena = false;   // Controla visibilidad de la contraseña
  bool _mantenerSesion = false;  // Checkbox "Mantener sesión iniciada"
  bool _cargando = false;        // Indicador de carga durante el login

  // Controlador y animaciones para la transición de entrada
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    // Configura la animación de aparición del formulario (opacidad + deslizamiento)
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    // Libera los controladores al salir de la pantalla
    _correoController.dispose();
    _contrasenaController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // Muestra un diálogo para ingresar correo y enviar restablecimiento de contraseña
  void _mostrarDialogoOlvideContrasena() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('RESTABLECER CONTRASEÑA',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tu correo institucional',
            hintStyle: const TextStyle(color: Colors.white60),
            filled: true, fillColor: Colors.white.withValues(alpha: 0.15),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(999), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            onPressed: () {
              final correo = controller.text.trim();
              if (correo.isNotEmpty) {
                Navigator.pop(context);
                _enviarOlvideContrasena(correo);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder()),
            child: const Text('ENVIAR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // Envía el correo de restablecimiento de contraseña a través de Firebase Auth
  Future<void> _enviarOlvideContrasena(String correo) async {
    final provider = context.read<AppProvider>();
    final error = await provider.olvideContrasena(correo);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Correo de restablecimiento enviado'),
        backgroundColor: error != null ? Colors.red : Colors.green,
      ),
    );
  }

  // Método que procesa el inicio de sesión
  Future<void> _ingresar() async {
    final correo = _correoController.text.trim();
    final pass = _contrasenaController.text.trim();

    // Validación de campos vacíos
    if (correo.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Completa todos los campos')));
      return;
    }

    setState(() => _cargando = true);
    final provider = context.read<AppProvider>();
    int esperas = 0;
    while (provider.cargando && esperas < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      esperas++;
    }
    if (!mounted) return;

    final error = await provider.iniciarSesion(correo, pass, recordar: _mantenerSesion);
    if (!mounted) return;
    setState(() => _cargando = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red));
      return;
    }

    if (provider.esAdmin) {
      Navigator.pushReplacementNamed(context, '/homeAdmin');
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fondo con gradiente y formulario de login centrado
    return BackgroundScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(children: [
                // Botón de retroceso para volver al splash
                Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/'),
                      child: Container(
                          width: 38, height: 38,
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20)))),
                const SizedBox(height: 16),
                // Logo de la aplicación
                Image.asset('assets/logo.png',
                    width: MediaQuery.of(context).size.width * 0.55),
                const SizedBox(height: 40),
                // Tarjeta tipo vidrio (GlassCard) con el formulario
                GlassCard(
                  padding: const EdgeInsets.all(28),
                  borderRadius: 24,
                  child: Column(children: [
                    const Text('INICIAR SESIÓN', style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.bold, color: Colors.white,
                        letterSpacing: 2)),
                    const SizedBox(height: 24),
                    // Campo de correo electrónico
                    _buildCampo(
                        controller: _correoController,
                        hint: 'Correo institucional',
                        icono: Icons.email_outlined,
                        teclado: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    // Campo de contraseña con opción de mostrar/ocultar
                    _buildCampo(
                        controller: _contrasenaController,
                        hint: 'Contraseña',
                        icono: Icons.lock_outline,
                        esContrasena: true),
                    const SizedBox(height: 8),
                    // Enlace "¿Olvidó su contraseña?"
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                            onPressed: () {
                              final correo = _correoController.text.trim();
                              if (correo.isEmpty) {
                                _mostrarDialogoOlvideContrasena();
                              } else {
                                _enviarOlvideContrasena(correo);
                              }
                            },
                            child: const Text('¿Olvidó su contraseña?',
                                style: TextStyle(
                                    color: Colors.white,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                    fontSize: 13)))),
                    // Checkbox "Mantener la sesión iniciada"
                    Row(children: [
                      Checkbox(
                          value: _mantenerSesion,
                          checkColor: AppColors.primary,
                          fillColor: WidgetStateProperty.all(Colors.white),
                          onChanged: (v) =>
                              setState(() => _mantenerSesion = v ?? false)),
                      const Text('Mantener la sesión iniciada',
                          style: TextStyle(
                              color: Colors.white, fontSize: 13)),
                    ]),
                    const SizedBox(height: 8),
                    // Separador decorativo con las siglas UTS
                    Row(children: [
                      const Expanded(child: Divider(color: Colors.white30)),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('UTS', style: TextStyle(
                              color: Colors.white54, fontSize: 12,
                              fontWeight: FontWeight.bold))),
                      const Expanded(child: Divider(color: Colors.white30)),
                    ]),
                    const SizedBox(height: 20),
                    // Botón "INGRESAR" con indicador de carga
                    SizedBox(width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _ingresar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(), elevation: 0),
                          child: _cargando
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Text('INGRESAR', style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15,
                                  letterSpacing: 1.5)))),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  // Construye un campo de texto estilizado con ícono y borde redondeado
  Widget _buildCampo({
    required TextEditingController controller,
    required String hint,
    required IconData icono,
    bool esContrasena = false,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: esContrasena && !_verContrasena, // Oculta texto si es contraseña
      keyboardType: teclado,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icono, color: Colors.white70, size: 20), // Ícono del campo
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: Colors.white, width: 1.5)),
        // Botón para mostrar/ocultar la contraseña
        suffixIcon: esContrasena
            ? IconButton(
                icon: Icon(_verContrasena
                    ? Icons.visibility
                    : Icons.visibility_off,
                    color: Colors.white70, size: 20),
                onPressed: () =>
                    setState(() => _verContrasena = !_verContrasena))
            : null,
      ),
    );
  }
}
