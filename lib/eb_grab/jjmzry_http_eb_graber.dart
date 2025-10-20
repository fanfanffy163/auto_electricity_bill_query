import 'dart:convert';
import 'package:auto_electricity_bill_query/eb_grab/eb_graber.dart';
import 'package:auto_electricity_bill_query/exception/app_exception.dart';
import 'package:auto_electricity_bill_query/utils/utils.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';


class JjmzryHttpEbGraber extends AbstractEbGraber{

  Future<Map<String,dynamic>?> query(String url) async{
    if(url.trim().isEmpty){
      throw AppException("缴费链接为空");
    }
    http.Response response = await http.get(Uri.parse(url), headers: {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0'
      });
    if (response.statusCode != 200) return null;

    final reg = RegExp(r'var GLOBAL\s*=\s*({.*?});', dotAll: true);
    final match = reg.firstMatch(response.body);
    if (match == null) return null;

    final globalJsonStr = Utils.jsObjectToJsonStrict(match.group(1) ?? '');
    if (globalJsonStr == "") return null;

    // 解析 JSON
    final global = json.decode(globalJsonStr);
    final cookie = response.headers['set-cookie'];
    return {"global" : global, "cookie": cookie ?? ''};
  }

  @override
  Future<EbData?> grab(String url) async {
    final queryRes = await query(url);
    return _extractEb(queryRes?['global']);
  }

  @override
  Future<bool> chargeEb(String url, PayType type, double amount) async {
    final queryRes = await query(url);
    return _chargeExec(url,queryRes, type, amount);
  }

  bool _chargeExec(String url, Map<String,dynamic>? queryRes, PayType type, double amount){
    final global = queryRes?['global'];
    if(global == null) return false;

    final payId = global['PAYREQUEST_URL'] as String?;
    if (payId == null) return false;
    final domain = '${Uri.parse(url).scheme}://${Uri.parse(url).host}';

    // 这里根据具体的业务逻辑实现扣费
    // 例如：
    if(type == PayType.alipay){
      // 调用支付宝扣费接口
      _alipay(domain + payId, amount, queryRes?['cookie']);
    } else if(type == PayType.wechatpay){
      
    }
    return true;
  }

  EbData? _extractEb(dynamic global) {
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

  // static Future<bool> _wxpay(String apiUrl, double amount, String cookie) async {
  //   final api = Uri.parse(apiUrl);
  //   final response = await http.post(api, body: {
  //       'amount': amount.toString(),
  //       'payType': "tqpay",
  //       'confirm': '1'
  //       // 其他必要的参数
  //     }, headers: {
  //       'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
  //       'Accept': 'application/json, text/javascript, */*; q=0.01',
  //       'X-Requested-With': 'XMLHttpRequest',
  //       'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36 NetType/WIFI MicroMessenger/7.0.20.1781(0x6700143B) WindowsWechat(0x63090a13) UnifiedPCWindowsWechat(0xf2541022) XWEB/16467 Flue',
  //       'Host': api.host,
  //       'Connection': 'Keep-Alive',
  //       'Origin': 'http://wx.tqdianbiao.com',
  //       'Cookie': cookie
  //     }
  //   );
  //   debugPrint('微信支付响应: ${response.body}');

  //   // 解析JSON
  //   Map<String, dynamic> info = json.decode(response.body);
    
  //   // 检查返回状态是否成功
  //   if (info['status'] != 1 || info['state'] != 'success') {
  //     return false;
  //   }
    
  //   // 提取支付相关信息
  //   Map<String, dynamic> data = info['info']['data'];
  //   String paySign = data['paySign']; // 支付跳转链接
    
  //   // 检查支付链接是否有效
  //   if (paySign.isEmpty) {
  //     return false;
  //   }

    
  // }

  static Future<bool> _alipay(String apiUrl, double amount, String cookie) async {
    final api = Uri.parse(apiUrl);
    final response = await http.post(api, body: {
        'amount': amount.toString(),
        'payType': "tq_alipay",
        'confirm': '1'
        // 其他必要的参数
      }, headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'X-Requested-With': 'XMLHttpRequest',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/139.0.0.0 Safari/537.36 Edg/139.0.0.0',
        'Host': api.host,
        'Connection': 'Keep-Alive',
        'Origin': 'http://wx.tqdianbiao.com',
        'Cookie': cookie
      }
    );
    debugPrint('支付宝支付响应: ${response.body}');

    // 解析JSON
    Map<String, dynamic> info = json.decode(response.body);
    
    // 检查返回状态是否成功
    if (info['status'] != 1 || info['state'] != 'success') {
      return false;
    }
    
    // 提取支付相关信息
    Map<String, dynamic> data = info['info']['data'];
    String payUrl = data['payUrl']; // 支付跳转链接
    
    // 检查支付链接是否有效
    if (payUrl.isEmpty) {
      return false;
    }
    
    // 发起支付跳转
    await _launchWithAppChooser(payUrl);
    // 支付宝支付
    // 这里实现支付宝支付的逻辑
    return true;
  }

  // 微信支付
  // 尝试打开链接，优先尝试微信
  // 打开链接并显示应用选择器
  static Future<bool> _launchWithAppChooser(String url) async {
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