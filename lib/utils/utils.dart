import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Utils{
  static void showMessage(BuildContext? context, String message){
    if(context == null){
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
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
}