import 'package:shared_preferences/shared_preferences.dart';

/// 缓存工具类
class CacheUtil {
  // 单例模式，使用私有构造函数和静态实例
  static final CacheUtil _instance = CacheUtil._internal();
  factory CacheUtil() => _instance;

  CacheUtil._internal();

  // SharedPreferences 实例
  static SharedPreferences? _prefs;

  /// 在应用程序启动时调用，初始化 SharedPreferences 实例
  static Future<void> init() async {
    if (_prefs != null) return; // 如果已经初始化，则直接返回
    _prefs = await SharedPreferences.getInstance();
  }

  /// 获取 SharedPreferences 实例
  static SharedPreferences? get prefs => _prefs;

  // --- 缓存操作方法 ---

  /// 设置缓存
  static Future<bool> setString(String key, String value) async {
    if (_prefs == null) {
      return false;
    }
    return _prefs!.setString(key, value);
  }

  /// 获取缓存
  static String? getString(String key) {
    if (_prefs == null) {
      return null;
    }
    return _prefs!.getString(key);
  }

  /// 设置布尔值
  static Future<bool> setBool(String key, bool value) async {
    if (_prefs == null) {
      return false;
    }
    return _prefs!.setBool(key, value);
  }

  /// 获取布尔值
  static bool? getBool(String key) {
    if (_prefs == null) {
      return null;
    }
    return _prefs!.getBool(key);
  }

  /// 设置整数
  static Future<bool> setInt(String key, int value) async {
    if (_prefs == null) {
      return false;
    }
    return _prefs!.setInt(key, value);
  }

  /// 获取整数
  static int? getInt(String key) {
    if (_prefs == null) {
      return null;
    }
    return _prefs!.getInt(key);
  }

  /// 设置双精度浮点数
  static Future<bool> setDouble(String key, double value) async {
    if (_prefs == null) {
      return false;
    }
    return _prefs!.setDouble(key, value);
  }

  /// 获取双精度浮点数
  static double? getDouble(String key) {
    if (_prefs == null) {
      return null;
    }
    return _prefs!.getDouble(key);
  }

  /// 设置字符串列表
  static Future<bool> setStringList(String key, List<String> value) async {
    if (_prefs == null) {
      return false;
    }
    return _prefs!.setStringList(key, value);
  }

  /// 获取字符串列表
  static List<String>? getStringList(String key) {
    if (_prefs == null) {
      return null;
    }
    return _prefs!.getStringList(key);
  }

  /// 移除指定键的缓存
  static Future<bool> remove(String key) async {
    if (_prefs == null) {
      return false;
    }
    return _prefs!.remove(key);
  }

  /// 清除所有缓存
  static Future<bool> clear() async {
    if (_prefs == null) {
      return false;
    }
    return _prefs!.clear();
  }
}