import 'dart:convert';

import 'package:auto_electricity_bill_query/eb_grab/eb_graber.dart';
import 'package:auto_electricity_bill_query/eb_grab/http_eb_graber.dart';
import 'package:auto_electricity_bill_query/utils/utils.dart';
import 'package:http/http.dart' as http;

class JjmzryHttpEbGraber extends HttpEbGraber{

  JjmzryHttpEbGraber(super.url);

  @override
  Future<EbData?> extractData(http.Response response) async {
    // 1. 用正则提取 GLOBAL 变量
    // 用正则提取 var GLOBAL = {...};
    final reg = RegExp(r'var GLOBAL\s*=\s*({.*?});', dotAll: true);
    final match = reg.firstMatch(response.body);
    if (match == null) return null;

    final globalJsonStr = Utils.jsObjectToJsonStrict(match.group(1) ?? '');
    if (globalJsonStr == "") return null;

    // 解析 JSON
    final global = json.decode(globalJsonStr);
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
}