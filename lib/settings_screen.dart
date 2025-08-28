import 'package:auto_electricity_bill_query/provider/fee_provider.dart';
import 'package:auto_electricity_bill_query/service/qrcode_scan_observer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart' show BarcodeCapture;
import 'package:provider/provider.dart';
import 'utils/cache.dart';
import 'utils/camera.dart';
import 'utils/utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  QrScanWidgetState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends QrScanWidgetState<SettingsScreen> {
  
  final TextEditingController _linkController = TextEditingController();
  late double _notificationThreshold;
  late int _refreshInterval;

  @override
  void initState() {
    super.initState();
    _linkController.text = FeeProvider.feeUrl;
    _notificationThreshold = FeeProvider.notificationThreshold;
    _refreshInterval = FeeProvider.refreshInterval;
  }

  @override
  void handleBarcode(BarcodeCapture barcode) {
    debugPrint(barcode.barcodes.first.rawValue);
    setState(() {
      _linkController.text = barcode.barcodes.first.rawValue ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle('缴费链接设置'),
              _buildLinkInput(),
              const SizedBox(height: 32),
              _buildSectionTitle('刷新规则设置'),
              _buildRuleSettingsCard(),
              const SizedBox(height: 40),
              _buildResetButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  List<Widget> getIcons(){
    List<IconButton> tmpList = [];
    if(_linkController.text != ''){
      tmpList.add(IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _linkController.clear(); // 清空输入框
                  CacheUtil.setString(FeeProvider.linkCacheKey, _linkController.text);
                });  
              }
            ));
    }
    tmpList.add(IconButton(
              icon: const Icon(FontAwesomeIcons.camera, color: Colors.black54, size: 20),
              onPressed: () async {
                await startQrScan();
              },
            ));
    tmpList.add(IconButton(
              icon: const Icon(FontAwesomeIcons.image, color: Colors.black54, size: 20),
              onPressed: () async {
                final String? text = await QrCodeScannerUtil.scanQrCodeFromGallery();
                if(!mounted) return;

                if(text == null){
                  Utils.showMessage(context, '读取二维码失败，请检查选中图片');
                  return;
                }
                _linkController.text = text;
                final feeProvider = context.read<FeeProvider>();
                final res = await feeProvider.refreshFee(url: text);
                if(!mounted) return;
                if(res){
                  Utils.showMessage(context, '电费已刷新！金额: ${feeProvider.currentFee} 元，采集时间: ${DateFormat('yyyy-MM-dd HH:mm').format(feeProvider.lastUpdated)}');
                  CacheUtil.setString(FeeProvider.linkCacheKey, _linkController.text);
                }
              },
            ));
    return tmpList;
  }

  Widget _buildLinkInput() {
    return TextField(
      controller: _linkController,
      maxLines: 3,
      keyboardType: TextInputType.url, // Set keyboard type to url
      textInputAction: TextInputAction.done, // Change action to 'Done'
      decoration: InputDecoration(
        hintText: '输入或扫描二维码获取链接',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...getIcons(),
            const SizedBox(width: 8),
          ],
        ),
      ),
      onChanged: (str){
        setState(() {
          CacheUtil.setString(FeeProvider.linkCacheKey, _linkController.text);
        });
      },
      // onSubmitted: (value) {
      //   // Unfocus the keyboard when the user submits
      //   FocusScope.of(context).unfocus();
      // },
    );
  }

  Widget _buildRuleSettingsCard() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          _buildNotificationRule(),
          const Divider(height: 32),
          _buildRefreshIntervalRule(),
        ],
      ),
    );
  }

  Widget _buildNotificationRule() {
    return Row(
      children: [
        const Icon(Icons.notifications_active_outlined, color: Colors.blue),
        const SizedBox(width: 16),
        const Expanded(child: Text('提醒阈值 (元)')),
        Text('${_notificationThreshold.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          width: 150,
          child: Slider(
            value: _notificationThreshold,
            min: 1,
            max: 30,
            divisions: 15,
            label: _notificationThreshold.round().toString(),
            onChanged: (double value) {
              setState(() {
                _notificationThreshold = value;
                CacheUtil.setDouble(FeeProvider.notifyThresholdCacheKey, _notificationThreshold);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRefreshIntervalRule() {
    return Row(
      children: [
        const Icon(Icons.timer_outlined, color: Colors.green),
        const SizedBox(width: 16),
        const Expanded(child: Text('刷新间隔 (小时)')),
        DropdownButton<int>(
          value: _refreshInterval,
          items: [1, 2, 4, 12, 24].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value 小时'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            setState(() {
              _refreshInterval = newValue!;
              CacheUtil.setInt(FeeProvider.refreshIntervalCacheKey, _refreshInterval);
            });
          },
          underline: Container(),
        ),
      ],
    );
  }

  Widget _buildResetButtons() {
    return Column(
      children: [
        OutlinedButton.icon(
          icon: const Icon(Icons.link_off),
          label: const Text('重置缴费链接'),
          onPressed: () {
            setState(() {
              _linkController.clear();
              CacheUtil.remove(FeeProvider.linkCacheKey);
            });
          },
          style: _resetButtonStyle(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.replay_circle_filled_outlined),
          label: const Text('重置刷新规则'),
          onPressed: () {
            setState(() {
              _notificationThreshold = FeeProvider.defaultNotificationThreshold;
              _refreshInterval = FeeProvider.defaultRefreshInterval;
              CacheUtil.remove(FeeProvider.notifyThresholdCacheKey);
              CacheUtil.remove(FeeProvider.refreshIntervalCacheKey);
            });
          },
          style: _resetButtonStyle(),
        ),
      ],
    );
  }

  ButtonStyle _resetButtonStyle() {
    return OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 50),
      foregroundColor: Colors.redAccent,
      side: const BorderSide(color: Colors.redAccent),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}