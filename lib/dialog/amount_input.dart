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
      content: TextField(
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

      // 按钮
      actions: <Widget>[
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
      ],
    );
  }
}