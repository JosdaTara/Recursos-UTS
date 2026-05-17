// Punto de entrada de la aplicación.
// Inicializa los servicios globales (notificaciones locales) y levanta el árbol de widgets con Provider.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/app_provider.dart';
import 'services/notificacion_service.dart';
import 'screens/start/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/login/register_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/menu_screen.dart';
import 'screens/user/perfil_screen.dart';
import 'screens/user/solicitar_prestamo_screen.dart';
import 'screens/user/mis_prestamos_screen.dart';
import 'screens/user/recursos_screen.dart';
import 'screens/admin/home_admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificacionService().init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UTS Préstamos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A6000),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5A6000),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: const StadiumBorder(),
            textStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/':         (context) => const SplashScreen(),
        '/login':    (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home':     (context) => const HomeScreen(),
        '/menu':     (context) => const MenuScreen(),
        '/perfil':   (context) => const PerfilScreen(),
        '/solicitar':(context) => const SolicitarPrestamoScreen(),
        '/prestamos':(context) => const MisPrestamosScreen(),
        '/recursos': (context) => const RecursosScreen(),
        '/homeAdmin': (context) => const HomeAdminScreen(),
      },
    );
  }
}