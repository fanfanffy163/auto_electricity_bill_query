// lib/providers/fee_provider.dart
import 'package:auto_electricity_bill_query/eb_grab/eb_graber.dart';
import 'package:auto_electricity_bill_query/eb_grab/jjmzry_http_eb_graber.dart';
import 'package:auto_electricity_bill_query/exception/app_exception.dart';
import 'package:auto_electricity_bill_query/utils/cache.dart';
import 'package:flutter/material.dart';

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

  void updateFee({required double fee, required DateTime updateTime}) {
    _currentFee = fee;
    _lastUpdated = updateTime;
    notifyListeners();
  }

  Future<bool> refreshFee({required String url}) async {
    _isLoading = true;
    notifyListeners();

    try {
      EbData c = await fetchFeeFromUrl(url);
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

  static Future<EbData> fetchFeeFromUrl(String url) async {
    AbstractEbGraber graber = JjmzryHttpEbGraber(url);
    EbData? c = await  graber.grab();
    // 假设抓取到的电费数据
    if (c == null) {
      throw AppException('获取电费失败，请检查链接或网络连接');
    }
    return c;
  }
}