import 'dart:io';

import 'package:auto_electricity_bill_query/exception/app_exception.dart';
import 'package:auto_electricity_bill_query/provider/fee_provider.dart';
import 'package:auto_electricity_bill_query/utils/logger.dart';
import 'package:auto_electricity_bill_query/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';

class ForegroundService {
  static Future<bool> isRunning() async{
    return await FlutterForegroundTask.isRunningService;
  }

  static Future<bool> run(Function ctxGeter) async{
    if(await FlutterForegroundTask.isRunningService){
      return false;
    }

    try{
      await _requestPermissions();
      _initForegroundTask();
      await _startForegroundService();
    }catch(e){
      if(e is AppException){
        Utils.showMessage(ctxGeter(),e.message,seconds: 5,action: SnackBarAction(label: "去设置", onPressed: openAppSettings));
      }else{
        rethrow;
      }
    }
    
    return true;
  }

  static Future<bool> stop() async{
    if(!await FlutterForegroundTask.isRunningService){
      return false;
    }

    FlutterForegroundTask.stopService();
    return true;
  }

  static Future<void> _requestPermissions() async {
    // Android 13+, you need to allow notification permission to display foreground service notification.
    //
    // iOS: If you need notification, ask for permission.
    final NotificationPermission notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }

    if(notificationPermission != NotificationPermission.granted){
      throw AppException('通知权限未授予,无法实现电费通知');
    }

    if (Platform.isAndroid) {
      // Android 12+, there are restrictions on starting a foreground service.
      //
      // To restart the service on device reboot or unexpected problem, you need to allow below permission.
      if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
        // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
        await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      }

      // // Use this utility only if you provide services that require long-term survival,
      // // such as exact alarm service, healthcare service, or Bluetooth communication.
      // //
      // // This utility requires the "android.permission.SCHEDULE_EXACT_ALARM" permission.
      // // Using this permission may make app distribution difficult due to Google policy.
      // if (!await FlutterForegroundTask.canScheduleExactAlarms) {
      //   // When you call this function, will be gone to the settings page.
      //   // So you need to explain to the user why set it.
      //   await FlutterForegroundTask.openAlarmsAndRemindersSettings();
      // }
    }
  }

  // 初始化前台任务配置
  static void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'foreground_service_channel',
          channelName: 'Foreground Service',
          channelDescription: '保持应用在前台运行',
          channelImportance: NotificationChannelImportance.DEFAULT,
          priority: NotificationPriority.DEFAULT,
          showWhen : true,
          showBadge : true,
        ),
        iosNotificationOptions: const IOSNotificationOptions(
          showNotification: true,
          playSound: false,
        ),
        foregroundTaskOptions: ForegroundTaskOptions(
          eventAction: ForegroundTaskEventAction.repeat(10 * 60 * 1000)
        )
      );  
  }

  // 启动前台服务
  static Future<void> _startForegroundService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return;
    }
    // 启动服务（Android 12+ 需用户交互后才能启动，避免冷启动时被系统拦截）
    await FlutterForegroundTask.startService(
      notificationTitle: '正在监控电费',
      notificationText: '点击返回应用',
      callback: startCallback,
      serviceTypes : [ForegroundServiceTypes.dataSync]
    );
  }

  // 服务回调逻辑
  static Future<void> foregroundTaskCallback(int taskId) async {
    try{
      await FeeProvider.execRefreshElectricityBill(taskId.toString());
    }catch(e){
      logger.e("foreground fetch fee error ",error: e);
    }
  }
}

// The callback function should always be a top-level or static function.
@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(FeeTaskHandler());
}

class FeeTaskHandler extends TaskHandler {
  static const String feeRefresh = 'feeRefresh';

  void _watchFee(DateTime timestamp){
    timestamp = timestamp.toLocal();
    final hour = timestamp.hour;
    //8点之前 22点之后就不要提醒了
    if(hour < 8 || hour > 22){
      return;
    }    
    _feeRefresh();   
  }

  void _feeRefresh() async{
    logger.i("foreground task refresh fee start");
    await FeeProvider.execRefreshElectricityBill(feeRefresh);
    logger.i("foreground task refresh fee end");
  }

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _watchFee(timestamp);
  }

  // Called based on the eventAction set in ForegroundTaskOptions.
  @override
  void onRepeatEvent(DateTime timestamp) {
    _watchFee(timestamp);
  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
  }

  // Called when data is sent using `FlutterForegroundTask.sendDataToTask`.
  @override
  void onReceiveData(Object data) {
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    logger.i('onNotificationButtonPressed: $id');
  }

  // Called when the notification itself is pressed.
  @override
  void onNotificationPressed() {
    logger.i('onNotificationPressed');
  }

  // Called when the notification itself is dismissed.
  @override
  void onNotificationDismissed() {
    logger.i('onNotificationDismissed');
  }
}

