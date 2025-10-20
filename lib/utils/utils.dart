import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Utils{
  static void showMessage(BuildContext? context, String message, {int? seconds, SnackBarAction? action}){
    if(context == null){
      return;
    }

    seconds ??= min(5, max(2, (message.length / 10).toInt()));

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 6, // 阴影增强悬浮感
          action: action,
          duration: Duration(seconds: seconds),
          behavior: SnackBarBehavior.floating, // 悬浮模式
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      );
  }

  static String jsObjectToJsonStrict(String js) {
    // 1. 去除换行和多余空格
    js = js.replaceAll('\n', '').replaceAll('\r', '');

    // 2. 用正则给所有未加引号的属性名加引号（支持嵌套）
    // 匹配 { key: 或 , key: 形式，key支持字母、数字、下划线
    js = js.replaceAllMapped(
      RegExp(r'([{,]\s*)([A-Za-z0-9_]+)\s*:', multiLine: true),
      (m) => '${m[1]}"${m[2]}":'
    );

    // 3. 替换单引号为双引号（如果有）
    js = js.replaceAll("'", '"');

    // 4. 去掉结尾多余逗号
    js = js.replaceAll(RegExp(r',\s*}'), '}');
    js = js.replaceAll(RegExp(r',\s*]'), ']');

    // 5. 处理 JS 布尔值和 null（如果有）
    js = js.replaceAllMapped(RegExp(r':\s*([a-zA-Z]+)'), (m) {
      final v = m[1];
      if (v == 'true' || v == 'false' || v == 'null') {
        return ': $v';
      }
      return m[0]!;
    });

    return js;
  }


  static Future<void> writeLog(String message) async {
    final dir = await getExternalStorageDirectory();
    if(dir == null) {
      debugPrint("无法获取外部存储目录");
      return;
    }
    final now = DateTime.now();
    final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final timeStr = now.toIso8601String();
    final file = File('${dir.path}/AppLog_$dateStr.log');
    await file.writeAsString('[$timeStr] $message\n', mode: FileMode.append, flush: true);
  }


  /// 时间戳转DateTime（支持毫秒/秒级时间戳）
  static DateTime timestampToDateTime(int timestamp) {
    // 判断是毫秒级（13位）还是秒级（10位）
    if (timestamp.toString().length == 13) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp); // 毫秒级
    } else {
      return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000); // 秒级
    }
  }

  static Future<bool> jumpUrl(String url) async{
    // 检查是否可以打开链接
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      return true;
    } else {
      return false;
    }
  }
}