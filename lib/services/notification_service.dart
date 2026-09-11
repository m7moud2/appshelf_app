import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Lightweight local notifications — ready for future push wiring.
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios, macOS: ios),
    );
    _ready = true;
  }

  Future<void> showAppUpdateAvailable(String version) async {
    await init();
    const android = AndroidNotificationDetails(
      'appshelf_updates',
      'تحديثات المتجر',
      channelDescription: 'تنبيهات عند توفر إصدار جديد من التطبيق',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await _plugin.show(
      1002,
      'تحديث متاح',
      'إصدار $version من رف التطبيقات متوفر — افتح المتجر للتحميل.',
      const NotificationDetails(
        android: android,
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> showCatalogTip() async {
    await init();
    const android = AndroidNotificationDetails(
      'appshelf_updates',
      'تحديثات المتجر',
      channelDescription: 'تنبيهات خفيفة حول التطبيقات الجديدة',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await _plugin.show(
      1001,
      'رف التطبيقات',
      'تطبيقات جديدة قد تكون متاحة في المتجر — اسحب للتحديث.',
      const NotificationDetails(
        android: android,
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }
}
