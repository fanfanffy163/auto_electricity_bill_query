import 'package:auto_electricity_bill_query/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrCodeScannerUtil {
  /// 从相册选择图片并解析二维码
  ///
  /// 返回解析到的二维码数据，如果未选择图片或未解析到，则返回 null。
  static Future<String?> scanQrCodeFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    // 检查用户是否选择了图片
    if (image == null) {
      return null;
    }

    // 使用新的 API 来解析图片中的二维码
    try {
      // 创建一个 Result 对象来保存解析结果
      final BarcodeCapture? capture = await MobileScannerPlatform.instance.analyzeImage(image.path);
      logger.i("scanned QR code: $capture");
      return capture?.barcodes[0].displayValue; // 返回二维码数据
    } catch (e) {
      // 可以在这里处理解析失败的异常
      logger.e("Error parsing QR code",error: e);
      return null;
    }
  }
}