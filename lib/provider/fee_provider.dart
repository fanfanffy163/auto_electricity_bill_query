// lib/providers/fee_provider.dart
import 'package:auto_electricity_bill_query/eb_grab/eb_graber.dart';
import 'package:auto_electricity_bill_query/eb_grab/jjmzry_http_eb_graber.dart';
import 'package:auto_electricity_bill_query/exception/app_exception.dart';
import 'package:auto_electricity_bill_query/service/notification_service.dart';
import 'package:auto_electricity_bill_query/utils/cache.dart';
import 'package:auto_electricity_bill_query/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FeeProvider with ChangeNotifier {
  double _currentFee = 0.0;
  DateTime _lastUpdated = DateTime.now();
  bool _isLoading = false;
  static final String _linkCacheKey = "eb_get_link";
  static final String _notifyThresholdCacheKey = "eb_notify_threshold";
  static final String _refreshIntervalCacheKey = "eb_refresh_interval";
  static final double _defaultNotificationThreshold = 5.0;
  static final int _defaultRefreshInterval = 2;

  double get currentFee => _currentFee;
  DateTime get lastUpdated => _lastUpdated;
  bool get isLoading => _isLoading;
  static String get linkCacheKey => _linkCacheKey;
  static String get notifyThresholdCacheKey => _notifyThresholdCacheKey;
  static String get refreshIntervalCacheKey => _refreshIntervalCacheKey;
  static double get defaultNotificationThreshold => _defaultNotificationThreshold;
  static int get defaultRefreshInterval => _defaultRefreshInterval;
  
  //获取配置信息
  static double get notificationThreshold => CacheUtil.getDouble(_notifyThresholdCacheKey) ?? _defaultNotificationThreshold;
  static int get refreshInterval => CacheUtil.getInt(_refreshIntervalCacheKey) ?? _defaultRefreshInterval;
  static String get feeUrl => CacheUtil.getString(_linkCacheKey) ?? "";

  static final AbstractEbGraber graber = JjmzryHttpEbGraber();

  void updateFee({required double fee, required DateTime updateTime}) {
    _currentFee = fee;
    _lastUpdated = updateTime;
    notifyListeners();
  }

  Future<bool> refreshFee({required String url}) async {
    _isLoading = true;
    notifyListeners();

    try {
      EbData c = await _fetchFeeFromUrl(url);
      updateFee(fee: c.fee, updateTime: c.updateTime);
      return true;
    } catch (e) {
      // 处理错误
      throw AppException('获取电费失败: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static Future<bool> chargeFee({required String url, required PayType type, required double amount}) async {
    try {
      bool success = await graber.chargeEb(url, type, amount);
      if (!success) {
        throw AppException('扣费失败，请稍后重试');
      }
      return true;
    } catch (e) {
      // 处理错误
      throw AppException('扣费失败: $e');
    }
  }

  static Future<EbData> _fetchFeeFromUrl(String url) async {
    EbData? c = await graber.grab(url);
    // 假设抓取到的电费数据
    if (c == null) {
      throw AppException('获取电费失败，请检查链接或网络连接');
    }
    return c;
  }


  static Future<void> execRefreshElectricityBill(String taskId) async {
    await CacheUtil.init(); // 确保缓存工具类已初始化
    // 调用我们封装好的静态方法来执行业务逻辑
    try{
      final fee = FeeProvider.notificationThreshold;
      if (feeUrl.isEmpty) {
        throw AppException("缴费链接为空，无法刷新电费");
      }
      final bill = await _fetchFeeFromUrl(feeUrl);
      debugPrint("电费刷新成功 (from BackgroundTaskService): $bill");
      if(bill.fee <= fee){
        final lastUpdated = bill.updateTime;
        final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(lastUpdated);
        await NotificationService().init(isHeadless: true); // 推荐这里手动调用
        await NotificationService().showNotification(
          '电费即将耗尽',
          '当前最新电费为: ${bill.fee} 元，最后更新时间为: $formattedTime',
        );
      }
    }catch (e) {
      await Utils.writeLog("Error in headless task: $e");
      rethrow;
    }
  }
}