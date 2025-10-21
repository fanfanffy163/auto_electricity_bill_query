import 'package:auto_electricity_bill_query/service/qrcode_scan_observer.dart';
import 'package:auto_electricity_bill_query/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' show BarcodeCapture;

class QRCodeScanScreen extends StatefulWidget {
  const QRCodeScanScreen({super.key});

  @override
  State<QRCodeScanScreen> createState() => _QRCodeScanScreen();
}

class _QRCodeScanScreen extends QrScanWidgetState<QRCodeScanScreen> {
  bool isNavigating = false;
  @override
  void handleBarcode(BarcodeCapture barcode) {
    logger.i(barcode.barcodes.first.rawValue);
    if(isNavigating) return;
    Navigator.pop(context, barcode.barcodes.first.rawValue ?? ''); // 扫描到二维码后返回上一页
    isNavigating = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('扫码设置缴费链接'),
      ),
      body: Center(
        child: attachScanner(),
      ),
    );
  }
}