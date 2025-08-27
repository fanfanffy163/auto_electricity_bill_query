// lib/services/background_service.dart

import 'package:auto_electricity_bill_query/eb_grab/eb_graber.dart';
import 'package:auto_electricity_bill_query/provider/fee_provider.dart';
import 'package:auto_electricity_bill_query/service/notification_service.dart';
import 'package:auto_electricity_bill_query/utils/cache.dart';
import 'package:auto_electricity_bill_query/utils/utils.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  // 核心的刷新逻辑
  static Future<EbData?> refreshElectricityBill() async {
    final url = CacheUtil.getString(FeeProvider.linkCacheKey) ?? "";
    if (url.isEmpty) {
      debugPrint("缴费链接为空，无法刷新电费");
      return null;
    }
    final bill = await FeeProvider.fetchFeeFromUrl(url);
    debugPrint("电费刷新成功 (from BackgroundTaskService): $bill");   
    return bill; 
  }

  static void execRefreshElectricityBill(String taskId) async {
    debugPrint("[BackgroundFetch] Headless event received: $taskId");
    await CacheUtil.init(); // 确保缓存工具类已初始化
    // 调用我们封装好的静态方法来执行业务逻辑
    try{
      final fee = FeeProvider.notificationThreshold;
      final bill = await BackgroundTaskService.refreshElectricityBill();
      if(bill != null) {
        if(bill.fee <= 50){
          final lastUpdated = bill.updateTime;
          final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(lastUpdated);
          await NotificationService().init(isHeadless: true); // 推荐这里手动调用
          await NotificationService().showNotification(
            '电费即将耗尽',
            '当前最新电费为: ${bill.fee} 元，最后更新时间为: $formattedTime',
          );
        }    
      } else {
        debugPrint("电费刷新失败，可能是链接错误或网络问题");
      }
    }catch (e) {
      await Utils.writeLog("[BackgroundFetch] Error in headless task: $e");
      // 这里可以添加错误处理逻辑，比如记录日志或发送通知
    }finally{
      BackgroundFetch.finish(taskId);
    }
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

  BackgroundTaskService.execRefreshElectricityBill(taskId);
}