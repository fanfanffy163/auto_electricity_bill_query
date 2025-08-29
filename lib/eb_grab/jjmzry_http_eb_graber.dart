import 'dart:convert';

import 'package:auto_electricity_bill_query/eb_grab/eb_graber.dart';
import 'package:auto_electricity_bill_query/exception/app_exception.dart';
import 'package:auto_electricity_bill_query/utils/utils.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class JjmzryHttpEbGraber extends AbstractEbGraber{

  Future<dynamic> queryGlobal(String url) async{
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    final reg = RegExp(r'var GLOBAL\s*=\s*({.*?});', dotAll: true);
    final match = reg.firstMatch(response.body);
    if (match == null) return null;

    final globalJsonStr = Utils.jsObjectToJsonStrict(match.group(1) ?? '');
    if (globalJsonStr == "") return null;

    // 解析 JSON
    final global = json.decode(globalJsonStr);
    return global;
  }

  @override
  Future<EbData?> grab(String url) async {
    final global = await queryGlobal(url);
    return extractEb(global);
  }

  @override
  Future<bool> chargeEb(String url, PayType type, double amount) async {
    final global = await queryGlobal(url);
    return chargeExec(url,global, type, amount);
  }

  bool chargeExec(String url, dynamic global, PayType type, double amount){
    if(global == null) return false;

    final payId = global['PAYREQUEST_URL'] as String?;
    if (payId == null) return false;
    final domain = '${Uri.parse(url).scheme}://${Uri.parse(url).host}';

    // 这里根据具体的业务逻辑实现扣费
    // 例如：
    if(type == PayType.alipay){
      // 调用支付宝扣费接口
    } else if(type == PayType.wechatpay){
      // 调用微信扣费接口
      launchWithAppChooser(url);
    }
    return true;
  }

  EbData? extractEb(dynamic global) {
    // 1. 用正则提取 GLOBAL 变量
    // 用正则提取 var GLOBAL = {...};
    if(global == null) return null;
    
    final dashboard = global['DATA']?['dashboard'];
    if (dashboard == null) return null;

    // 解析JS返回的结果
    double? fee;
    if (dashboard['value'] is num) {
      fee = (dashboard['value'] as num).toDouble();
    } else if (dashboard['value'] != null) {
      fee = double.tryParse(dashboard['value'].toString());
    }

    // 提取采集时间
    DateTime? collectTime;
    if (dashboard['items'] is List) {
      for (final item in dashboard['items']) {
        if (item is Map && item['title'] == '采集时间') {
          collectTime = DateTime.tryParse(item['value']?.toString() ?? '');
          break;
        }
      }
    }

    if (fee != null && collectTime != null) {
      return EbData(fee, collectTime); // 根据你的EbData结构调整
    }
    return null;
  }

  // 微信支付
  // 尝试打开链接，优先尝试微信
  // 打开链接并显示应用选择器
  static Future<bool> launchWithAppChooser(String url) async {
    try {
      // 1. 解析并验证URL
      final uri = Uri.parse(url);
      if (!uri.isAbsolute) {
        debugPrint('无效的URL格式: $url');
        return false;
      }

      // 2. 检查是否可以打开该URL
      if (!await canLaunchUrl(uri)) {
        debugPrint('没有应用可处理该URL: $url');
        return false;
      }

      // 3. 启动链接并显示应用选择器
      // 使用externalApplication模式，会触发系统应用选择器
      return await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        // 可选：添加标题（部分系统会在选择器中显示）
        webOnlyWindowName: '打开链接',
      );
    } catch (e) {
      debugPrint('打开链接失败: $e');
      return false;
    }
  }
}