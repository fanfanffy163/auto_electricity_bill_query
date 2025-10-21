import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static PackageInfo? _packageInfo;

  static Future<void> init() async{
    _packageInfo ??= await PackageInfo.fromPlatform();
  }

  static String getAppVersion(){
    if(_packageInfo == null){
      return "未知";
    }
    return _packageInfo!.version;
  }
}