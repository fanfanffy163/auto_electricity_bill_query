import 'package:flutter/material.dart';

/// 一个通用的金额输入弹窗
/// 包含一个输入框、取消和确认按钮。
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

class _AmountInputDialogState extends State<AmountInputDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAmount.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: widget.hintText,
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            // 返回 null 表示取消
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () {
            try {
              final newAmount = double.parse(_controller.text);
              // 返回新金额
              Navigator.of(context).pop(newAmount);
            } catch (e) {
              // 输入无效，返回 null
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}