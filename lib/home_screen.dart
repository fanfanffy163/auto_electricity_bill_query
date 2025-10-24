import 'package:auto_electricity_bill_query/const.dart';
import 'package:auto_electricity_bill_query/dialog/amount_input.dart';
import 'package:auto_electricity_bill_query/dialog/info.dart';
import 'package:auto_electricity_bill_query/eb_grab/eb_graber.dart';
import 'package:auto_electricity_bill_query/provider/fee_provider.dart';
import 'package:auto_electricity_bill_query/service/foreground_service.dart';
import 'package:auto_electricity_bill_query/utils/cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intro/flutter_intro.dart';
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
  late Future<bool> _taskType;

  @override
  void initState() {
    super.initState();
    _taskType = ForegroundService.isRunning();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('电费小助手'),
        actions: [
          IntroStepBuilder(
            order: 3,
            text: '3. 点此查看使用说明',
            builder: (BuildContext context, GlobalKey key) {
              return IconButton(
                key: key,
                icon: const Icon(Icons.help),
                onPressed: () {
                  InfoDialog("应用信息").show(context);
                },
              );
            }
          ),
          IntroStepBuilder(
            onWidgetLoad: () {
              final firstOpen = CacheUtil.getBool(Configs.appFirstOpenHome) ?? true;
              if(firstOpen){
                CacheUtil.setBool(Configs.appFirstOpenHome, false);
                Intro.of(context).start();               
              }
            },
            order: 1,
            text: '1. 设置缴费链接和提醒规则',
            builder: (BuildContext context, GlobalKey key) {
              return IconButton(
                key: key,
                icon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              );
            },
          ),     
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              _buildFeeDisplayCard(),
              const SizedBox(height: 40),
              _buildPaymentButtons(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildStartBtn(),
      floatingActionButtonLocation : FloatingActionButtonLocation.centerFloat
    );
  }

  Widget _buildStartBtn(){
    return IntroStepBuilder(
        order: 2,
        text: '2. 启动前台任务进行监控电费，低于设定阈值将会通知提醒',
        builder: (BuildContext context, GlobalKey key){ 
          return FutureBuilder(
            key: key,
            future: _taskType,
            builder: (context, snapshot) {
              return FloatingActionButton.extended(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                onPressed: () async{
                  bool tmp = false;
                  if(snapshot.hasData && snapshot.data!){
                    await ForegroundService.stop();
                    tmp = false;
                  }else{
                    tmp = await ForegroundService.run((){
                      if(!mounted) return null;
                      return context;
                    });
                  }

                  if(!mounted) return;
                  setState(() {
                    _taskType = Future.value(tmp);
                  });
                },
                icon: snapshot.hasData && snapshot.data! ? Icon(Icons.stop) : Icon(Icons.play_arrow),
                label: snapshot.hasData && snapshot.data! ? const Text('终止监控') : const Text('开启监控'),
              );
            }
          );
        }
    );
  }

  Widget _buildFeeDisplayCard() {
    return Consumer<FeeProvider>(
      builder: (context, feeProvider, child) {
        return FeeDisplayer(feeProvider: feeProvider,);
      },
    );
  }
  

  Widget _buildPaymentButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: SvgPicture.asset('assets/icons/wechat_pay.svg', height: 24),
            label: const Text('微信缴费', style: TextStyle(fontSize: 16)),
            onPressed: () async {
              Utils.showMessage(context, "由于平台安全规则，此app内微信缴费无法实现，请前往微信app进行缴费或使用支付宝");
            },
            style: _paymentButtonStyle(const Color.fromARGB(255, 168, 176, 172)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: SvgPicture.asset('assets/icons/alipay.svg', height: 24),
            label: const Text('支付宝缴费', style: TextStyle(fontSize: 16)),
            onPressed: () async{ 
              final newAmount = await showDialog<double>(
                context: context,
                builder: (BuildContext context) {
                  // 使用通用的 AmountInputDialog
                  return AmountInputDialog(
                    title: '请输入需要充值的电费', // 传入自定义标题
                    initialAmount: 0,
                  );
                },
              );

              if(newAmount == null || newAmount <= 0){
                return;
              }
              await FeeProvider.chargeFee(url: FeeProvider.feeUrl, type: PayType.alipay, amount: newAmount);
            },
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

class FeeDisplayer extends StatefulWidget {
  const FeeDisplayer({
    super.key,
    required this.feeProvider,
  });

  final FeeProvider feeProvider;

  @override
  State<FeeDisplayer> createState() => _FeeDisplayerState();
}

class _FeeDisplayerState extends State<FeeDisplayer> {
  @override
  void initState() {
    super.initState();
    // 页面渲染后再刷新，避免 context 问题
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFee();
    });
  }

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
  Widget build(BuildContext context) {
    final feeProvider = widget.feeProvider;
    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(26),
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
          FittedBox(
            fit: BoxFit.scaleDown, // 缩放模式，通常用 scaleDown
            child: Text(
              '¥ ${feeProvider.currentFee.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
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
}