import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionService {
  static Future<void> request() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }
}
