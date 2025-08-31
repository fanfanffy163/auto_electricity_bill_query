import 'dart:async';

import 'package:auto_electricity_bill_query/qrcode_scan_screen.dart';
import 'package:auto_electricity_bill_query/exception/app_exception.dart';
import 'package:auto_electricity_bill_query/provider/fee_provider.dart';
import 'package:auto_electricity_bill_query/service/background_service.dart';
import 'package:auto_electricity_bill_query/service/notification_service.dart';
import 'package:auto_electricity_bill_query/utils/utils.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'utils/cache.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  FlutterError.onError = (FlutterErrorDetails details) {
    _handleError(details.exception, details.stack);
    FlutterError.presentError(details);
  };

  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    NotificationService().init(); // 推荐这里手动调用
    BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    await CacheUtil.init(); // 在这里进行初始化

    runApp(
      ChangeNotifierProvider(
        create: (_) => FeeProvider(),
        child: MyApp(),
      ),
    );
  }, (error, stack) {
    _handleError(error, stack);
  });
}

void _handleError(Object error, StackTrace? stack) {
  if (error is AppException) {
    // 用全局 navigatorKey 弹出提示
    final ctx = navigatorKey.currentState?.overlay?.context;
    if (ctx != null) {
      Utils.showMessage(ctx, error.message);
    }
  } else {
    // 其他异常可记录或上报
    debugPrint('未处理异常: $error');
    Utils.writeLog('未处理异常: $error\nStackTrace: $stack');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    await BackgroundTaskService.init();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 🌟 关键改动在这里
      title: '电费监控',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'PingFang SC', // 你可以替换成任何你喜欢的中文字体
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F7FA),
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007BFF)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/scanQrCode': (context) => const QRCodeScanScreen(),
      },
    );
  }
}