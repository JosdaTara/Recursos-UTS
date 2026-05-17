// Pantalla de registro de nuevos usuarios con formulario completo:
// datos personales (nombre, correo, documento), selección de programa
// académico y confirmación de contraseña. Incluye validaciones básicas.

import 'package:flutter/material.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';
import 'package:flutter_recursos_uts/widgets/glass_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  // Controladores para cada campo del formulario
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _confirmarController = TextEditingController();

  // Estado de la UI
  bool _verContrasena = false;   // Muestra/oculta la contraseña
  bool _verConfirmar = false;    // Muestra/oculta la confirmación
  bool _cargando = false;        // Indicador de carga al enviar el registro
  String? _programaSeleccionado; // Programa académico seleccionado

  // Controlador y animaciones para la transición de entrada
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Lista de programas académicos disponibles para seleccionar
  final List<String> _programas = [
    'TECNOLOGÍA EN DESARROLLO DE SISTEMAS INFORMÁTICOS',
    'TECNOLOGÍA EN GESTIÓN EMPRESARIAL',
    'TECNOLOGÍA EN ELECTRÓNICA',
    'TECNOLOGÍA EN CONTABILIDAD SISTEMATIZADA',
    'TECNOLOGÍA EN LOGÍSTICA',
    'TECNOLOGÍA EN SEGURIDAD Y SALUD EN EL TRABAJO',
  ];

  @override
  void initState() {
    super.initState();
    // Configura la animación de aparición del formulario
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
    // Libera los controladores de texto y animación
    _nombreController.dispose();
    _correoController.dispose();
    _documentoController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // Procesa el registro del nuevo usuario
  Future<void> _registrar() async {
    final nombre = _nombreController.text.trim();
    final correo = _correoController.text.trim();
    final doc = _documentoController.text.trim();
    final pass = _contrasenaController.text;
    final confirm = _confirmarController.text;

    // Validación: todos los campos deben estar llenos, incluido el programa
    if (nombre.isEmpty || correo.isEmpty || doc.isEmpty || pass.isEmpty ||
        confirm.isEmpty || _programaSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa todos los campos')));
      return;
    }
    // Validación: el correo debe contener al menos un @
    if (!correo.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Correo inválido')));
      return;
    }
    // Validación: las contraseñas deben coincidir
    if (pass != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden'),
              backgroundColor: Colors.red));
      return;
    }

    setState(() => _cargando = true);
    // Simula el envío de datos al servidor
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Muestra mensaje de éxito y redirige al login
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cuenta creada exitosamente!'),
            backgroundColor: AppColors.primary));
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Construye un campo de texto estilizado con ícono y opción de mostrar/ocultar
  Widget _buildCampo({
    required TextEditingController controller,
    required String hint,
    required IconData icono,
    bool esContrasena = false,
    bool verTexto = false,
    VoidCallback? onToggleVer,
    TextInputType teclado = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: esContrasena && !verTexto, // Oculta el texto si es contraseña
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
                icon: Icon(verTexto
                    ? Icons.visibility
                    : Icons.visibility_off,
                    color: Colors.white70, size: 20),
                onPressed: onToggleVer)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fondo con gradiente y formulario de registro centrado
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
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/'),
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
                // Tarjeta tipo vidrio (GlassCard) con el formulario de registro
                GlassCard(
                  padding: const EdgeInsets.all(28),
                  borderRadius: 24,
                  child: Column(children: [
                    const Text('REGISTRARSE', style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.bold, color: Colors.white,
                        letterSpacing: 2)),
                    const SizedBox(height: 24),
                    // Campo: Nombre completo
                    _buildCampo(controller: _nombreController,
                        hint: 'Nombre completo', icono: Icons.person_outline),
                    const SizedBox(height: 12),
                    // Campo: Correo institucional
                    _buildCampo(controller: _correoController,
                        hint: 'Correo institucional',
                        icono: Icons.email_outlined,
                        teclado: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    // Campo: Número de documento
                    _buildCampo(controller: _documentoController,
                        hint: 'Número de documento',
                        icono: Icons.badge_outlined,
                        teclado: TextInputType.number),
                    const SizedBox(height: 12),
                    // Selector de programa académico (Dropdown)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3))),
                      child: Row(children: [
                        const Icon(Icons.school_outlined,
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _programaSeleccionado,
                              hint: const Text('Programa académico',
                                  style: TextStyle(
                                      color: Colors.white60, fontSize: 14)),
                              isExpanded: true,
                              dropdownColor: AppColors.primary,
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  color: Colors.white70),
                              onChanged: (v) => setState(
                                  () => _programaSeleccionado = v),
                              items: _programas.map((p) =>
                                  DropdownMenuItem(value: p,
                                      child: Text(p, style: const TextStyle(
                                          color: Colors.white, fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis)))
                                  .toList(),
                            ))),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    // Campo: Contraseña
                    _buildCampo(controller: _contrasenaController,
                        hint: 'Contraseña', icono: Icons.lock_outline,
                        esContrasena: true, verTexto: _verContrasena,
                        onToggleVer: () => setState(
                            () => _verContrasena = !_verContrasena)),
                    const SizedBox(height: 12),
                    // Campo: Confirmar contraseña
                    _buildCampo(controller: _confirmarController,
                        hint: 'Confirmar contraseña',
                        icono: Icons.lock_outline,
                        esContrasena: true, verTexto: _verConfirmar,
                        onToggleVer: () => setState(
                            () => _verConfirmar = !_verConfirmar)),
                    const SizedBox(height: 20),
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
                    // Botón "CREAR CUENTA" con indicador de carga
                    SizedBox(width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _registrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(), elevation: 0),
                          child: _cargando
                              ? const SizedBox(width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5))
                              : const Text('CREAR CUENTA', style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15,
                                  letterSpacing: 1.5)))),
                    const SizedBox(height: 16),
                    // Enlace para ir al login si ya tiene cuenta
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                          '¿Ya tienes cuenta? Inicia sesión',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white, fontSize: 13)),
                    ),
                  ]),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
