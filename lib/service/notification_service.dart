// lib/services/notification_service.dart

import 'package:auto_electricity_bill_query/utils/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  // 使用单例模式，确保只有一个实例
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isGranted = false;
  FlutterLocalNotificationsPlugin get _notificationsPlugin => FlutterLocalNotificationsPlugin();

  Future<bool> init({bool isHeadless = false}) async {
    if (_isGranted) return _isGranted; // 如果已经初始化，则直接返回

    // Android 13+ 主动申请通知权限
    if (!isHeadless && defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      logger.i('通知权限状态: $status');
    }

    // Android 初始化设置
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // 使用应用的启动图标

    // iOS 初始化设置
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // 请求 Android 13+ 的通知权限
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            'electricity_bill_channel', // id
            '电费刷新通知', // name
            description: '用于显示电费不足时的通知', // description
            importance: Importance.defaultImportance,
        ));
    
    // 请求iOS权限
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    final bool? isGranted = await FlutterLocalNotificationsPlugin()
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.areNotificationsEnabled();
    if (isGranted != null && isGranted == true) {
      _isGranted = isGranted;
      logger.i("[NotificationService] 通知权限已授予");
    } else {
      logger.i("[NotificationService] 通知权限未授予");
    }
    return _isGranted;
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'electricity_bill_channel', // 之前创建的 channel id
      '电费刷新通知',
      channelDescription: '用于显示电费不足时的通知',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'ticker',
      onlyAlertOnce: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      0, // 通知ID
      title,
      body,
      platformChannelSpecifics,
    );
    logger.i ("[NotificationService] 显示通知: $title - $body");
  }
}