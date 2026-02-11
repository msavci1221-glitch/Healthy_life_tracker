import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Şimdilik boş — ileride bildirime tıklama ekleyebiliriz
      },
    );
  }

  static Future<void> showMealResult({
    required String foodName,
    required double calories,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'meal_channel',
      'Meal Analyze',
      channelDescription: 'Meal calorie results',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    // 🔑 UNIQUE ID (çok önemli)
    final notificationId = Random().nextInt(100000);

    await _plugin.show(
      notificationId,
      '🍽️ Meal Analyzed',
      '$foodName yaklaşık ${calories.toStringAsFixed(0)} kcal içeriyor',
      details,
    );
  }
}
