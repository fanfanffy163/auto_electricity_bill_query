import 'package:flutter/material.dart';

class AmountInputDialog extends StatefulWidget {
  final String title;
  final String hintText;
  final double initialAmount;

  const AmountInputDialog({
    super.key,
    required this.title,
    this.hintText = '请输入金额',
    this.initialAmount = 0.0,
  });

  @override
  State<AmountInputDialog> createState() => _AmountInputDialogState();
}

class _AmountInputDialogState extends State<AmountInputDialog> with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late AnimationController _animeController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAmount.toString());
    // 初始化动画（首次加载时晃动一次）
    _animeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 20).chain(
          CurveTween(curve: Curves.easeOut),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 20, end: 0).chain(
          CurveTween(curve: Curves.easeIn),
        ),
        weight: 50,
      ),
    ]).animate(_animeController);
    _animeController.forward(); // 触发动画
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // 添加圆角和阴影
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 10.0,      
      // 标题
      title: Text(
        widget.title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      // 内容
      content: _buildContent(context),
      // 按钮
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:Color.fromARGB(255, 182, 180, 180),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        child: const Text(
          '取消',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      ElevatedButton(
        onPressed: () {
          try {
            final newAmount = double.tryParse(_controller.text);
            if (newAmount != null) {
              Navigator.of(context).pop(newAmount);
            } else {
              Navigator.of(context).pop();
            }
          } catch (e) {
            Navigator.of(context).pop();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
          ),
        ),
        child: const Text(
          '确定',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    ];
  }

  Column _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: widget.hintText,
            // 添加边框
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
            // 选中时的边框颜色
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation.value, 0), // 水平方向晃动
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          _controller.text = "10.00";
                        },
                        child: Text("10元"),
                      ),
                      TextButton(
                        onPressed: () {
                          _controller.text = "20.00";
                        },
                        child: Text("20元"),
                      ),
                      TextButton(
                        onPressed: () {
                          _controller.text = "30.00";
                        },
                        child: Text("30元"),
                      ),
                      TextButton(
                        onPressed: () {
                          _controller.text = "50.00";
                        },
                        child: Text("50元"),
                      ),
                      TextButton(
                        onPressed: () {
                          _controller.text = "100.00";
                        },
                        child: Text("100元"),
                      ),
                    ],
                  )
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}