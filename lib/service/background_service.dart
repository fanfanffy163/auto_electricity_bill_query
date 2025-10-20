// lib/services/background_service.dart
import 'package:auto_electricity_bill_query/provider/fee_provider.dart';
import 'package:auto_electricity_bill_query/utils/utils.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';

class BackgroundTaskService {
  // 这是给 configure 用的回调，当应用在前台时会调用
  // 把它设为静态方法，这样 main.dart 就可以直接通过类名调用
  static void onBackgroundFetch(String taskId) async {
    debugPrint("[BackgroundFetch] Event received: $taskId");
    // 你可以在这里添加一些前台特定的逻辑，比如发一个本地通知
    // 但核心的刷新逻辑我们还是依赖 headlessTask
    //execRefreshElectricityBill(taskId);
  }

  // 这是给 configure 用的超时回调
  static void onBackgroundFetchTimeout(String taskId) {
    debugPrint("[BackgroundFetch] TIMEOUT: $taskId");
    //execRefreshElectricityBill(taskId);
  }

  static Future<void> init() async {
    // 配置 BackgroundFetch
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,//FeeProvider.refreshInterval * 60, // 这里使用配置的刷新间隔
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.ANY, // 允许任何网络类型
        // ... 其他配置
      ),
      // ✨ 使用你新定义的静态方法作为回调
      BackgroundTaskService.onBackgroundFetch,
      BackgroundTaskService.onBackgroundFetchTimeout
    );
    debugPrint("[BackgroundFetch] Configured with interval: ${FeeProvider.refreshInterval * 60} minutes");
  }

  
}

// 这个 headless task 入口函数仍然需要是顶级的
@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  await Utils.writeLog("Headless task started: ${task.taskId} at ${DateTime.now().toIso8601String()}");
  String taskId = task.taskId;
  if (task.timeout) {
    debugPrint("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }

  try{
    await FeeProvider.execRefreshElectricityBill(taskId);
  }catch(e){
    debugPrint("headless fetch fee error $e");
  }finally{
    BackgroundFetch.finish(taskId);
  }
}