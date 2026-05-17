// Servicio singleton para mostrar notificaciones en el sistema operativo del celular
// (bandeja de notificaciones de Android/iOS), independientemente de las notificaciones internas de la app.
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificacionService {
  // --- Singleton ---
  static final NotificacionService _instancia = NotificacionService._();
  factory NotificacionService() => _instancia;
  NotificacionService._();

  // Plugin de flutter_local_notifications
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Contador incremental para que cada notificación tenga un ID único
  int _id = 0;

  // Inicializa el plugin con la configuración para Android e iOS
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _onTap,
    );
  }

  // Callback cuando el usuario toca la notificación en la bandeja del sistema
  void _onTap(NotificationResponse res) {}

  // Muestra una notificación local en el dispositivo
  Future<void> mostrarNotificacion({
    required String titulo,
    required String cuerpo,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'prestamos_uts',
      'Préstamos UTS',
      channelDescription: 'Notificaciones de préstamos de recursos UTS',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      _id++,        // ID único para cada notificación
      titulo,
      cuerpo,
      details,
    );
  }
}
