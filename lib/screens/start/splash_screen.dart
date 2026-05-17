// Pantalla de bienvenida (Splash Screen) que se muestra al iniciar la app.
// Contiene el logo, el nombre del sistema y botones para iniciar sesión o registrarse,
// con animaciones secuenciales de aparición.

import 'package:flutter/material.dart';
import 'package:flutter_recursos_uts/theme/app_theme.dart';
import 'package:flutter_recursos_uts/widgets/background_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controladores de animación para logo, texto y botones
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonsController;

  // Animaciones del logo: opacidad y escala
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  // Animaciones del texto: opacidad y deslizamiento vertical
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  // Animaciones de los botones: opacidad y deslizamiento vertical
  late Animation<double> _buttonsFade;
  late Animation<Offset> _buttonsSlide;

  @override
  void initState() {
    super.initState();
    // Inicializa los controladores de animación con duraciones específicas
    _logoController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _buttonsController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));

    // Define las transiciones del logo: aparece y escala de 0.7 a 1.0
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.easeIn));
    _logoScale = Tween<double>(begin: 0.7, end: 1).animate(
        CurvedAnimation(parent: _logoController, curve: Curves.elasticOut));

    // Texto: aparece con deslizamiento desde abajo
    _textFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _textController, curve: Curves.easeOut));

    // Botones: aparecen con deslizamiento desde abajo
    _buttonsFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _buttonsController, curve: Curves.easeIn));
    _buttonsSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _buttonsController, curve: Curves.easeOut));

    // Ejecuta las animaciones en secuencia: logo -> texto -> botones
    _logoController.forward().then((_) => _textController.forward().then(
        (_) => _buttonsController.forward()));
  }

  @override
  void dispose() {
    // Libera los controladores de animación para evitar fugas de memoria
    _logoController.dispose();
    _textController.dispose();
    _buttonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fondo con gradiente y contenido animado
    return BackgroundScaffold(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(children: [
          const Spacer(flex: 2),

          // Sección del logo con animación de opacidad y escala
          FadeTransition(
            opacity: _logoFade,
            child: ScaleTransition(
              scale: _logoScale,
              child: Column(children: [
                Image.asset('assets/logo.png',
                    width: MediaQuery.of(context).size.width * 0.6),
                const SizedBox(height: 10),
              ]),
            ),
          ),
          const Spacer(flex: 1),

          // Sección del texto "SISTEMA DE PRÉSTAMOS / RECURSOS INFORMÁTICOS"
          FadeTransition(
            opacity: _textFade,
            child: SlideTransition(
              position: _textSlide,
              child: Column(children: [
                // Línea decorativa superior
                Container(
                    width: 50, height: 2, color: Colors.white60,
                    margin: const EdgeInsets.only(bottom: 16)),
                const Text('SISTEMA DE PRÉSTAMOS',
                    textAlign: TextAlign.center, style: TextStyle(
                        color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.bold, letterSpacing: 2)),
                const SizedBox(height: 4),
                const Text('RECURSOS INFORMÁTICOS',
                    textAlign: TextAlign.center, style: TextStyle(
                        color: Colors.white, fontSize: 20,
                        fontWeight: FontWeight.bold, letterSpacing: 2)),
                // Línea decorativa inferior
                Container(
                    width: 50, height: 2, color: Colors.white60,
                    margin: const EdgeInsets.only(top: 16)),
              ]),
            ),
          ),
          const Spacer(flex: 2),

          // Sección de botones de acción (Iniciar sesión y Registrarse)
          FadeTransition(
            opacity: _buttonsFade,
            child: SlideTransition(
              position: _buttonsSlide,
              child: Column(children: [
                // Botón "INICIAR SESIÓN" -> navega a la pantalla de login
                SizedBox(width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder(), elevation: 0),
                      child: const Text('INICIAR SESIÓN', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15,
                          letterSpacing: 1.2)))),
                const SizedBox(height: 14),
                // Botón "REGISTRARSE" -> navega a la pantalla de registro
                SizedBox(width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, '/register'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(
                            color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const StadiumBorder()),
                      child: const Text('REGISTRARSE', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15,
                          letterSpacing: 1.2)))),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
