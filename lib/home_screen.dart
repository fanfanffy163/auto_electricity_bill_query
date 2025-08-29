import 'package:auto_electricity_bill_query/eb_grab/eb_graber.dart';
import 'package:auto_electricity_bill_query/provider/fee_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart'; // 需要添加 intl 包来格式化时间
import 'package:provider/provider.dart';
import 'utils/utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  void _refreshFee() async{
    final url = FeeProvider.feeUrl;
    if (url.isEmpty) {
      Utils.showMessage(context, '缴费链接为空');
      return;
    }
    final feeProvider = context.read<FeeProvider>();
    await feeProvider.refreshFee(url: url);
    if (!mounted) {
      // 如果 Widget 已经不在树中，直接返回，不做任何操作
      return;
    }
    Utils.showMessage(context, '电费已刷新！金额: ${feeProvider.currentFee} 元，采集时间: ${DateFormat('yyyy-MM-dd HH:mm').format(feeProvider.lastUpdated)}');
  }

  @override
  void initState() {
    super.initState();
    // 页面渲染后再刷新，避免 context 问题
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFee();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('电费小助手'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          children: [
            _buildFeeDisplayCard(),
            const SizedBox(height: 40),
            _buildPaymentButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeDisplayCard() {
    final feeProvider = context.watch<FeeProvider>();

    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('当前电费 (元)', style: TextStyle(fontSize: 18, color: Colors.grey)),
              GestureDetector(
                onTap: feeProvider.isLoading ? null : () async => {
                  _refreshFee()
                },
                child: feeProvider.isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3))
                    : const Icon(Icons.refresh, color: Color(0xFF007BFF), size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '¥ ${feeProvider.currentFee.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.update, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '更新于: ${DateFormat('yyyy-MM-dd HH:mm').format(feeProvider.lastUpdated)}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildPaymentButtons() {
    final feeProvider = context.watch<FeeProvider>();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: SvgPicture.asset('assets/icons/wechat_pay.svg', height: 24),
            label: const Text('微信缴费', style: TextStyle(fontSize: 16)),
            onPressed: () async {
              await feeProvider.chargeFee(url: FeeProvider.feeUrl, type: PayType.wechatpay, amount: 1);
            },
            style: _paymentButtonStyle(const Color(0xFF07C160)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: SvgPicture.asset('assets/icons/alipay.svg', height: 24),
            label: const Text('支付宝缴费', style: TextStyle(fontSize: 16)),
            onPressed: () { /* TODO: 实现支付宝缴费逻辑 */ },
            style: _paymentButtonStyle(const Color(0xFF00A1FF)),
          ),
        ),
      ],
    );
  }

  ButtonStyle _paymentButtonStyle(Color backgroundColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
    );
  }
}