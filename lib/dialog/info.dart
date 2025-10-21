import 'package:auto_electricity_bill_query/const.dart';
import 'package:auto_electricity_bill_query/utils/app_info.dart';
import 'package:auto_electricity_bill_query/utils/utils.dart';
import 'package:flutter/material.dart';

class InfoDialog extends StatelessWidget {
  InfoDialog(this.message) : super(key: _dialogKey);

  final String message;
  static final _dialogKey = GlobalKey(debugLabel: 'info dialog');

  Future<void> show(BuildContext context) async {
    if (_dialogKey.currentContext == null) {
      return showDialog(
        context: context,
        useRootNavigator: true,
        builder: (context) => this,
      );
    } else {
      //logger.d("new version dialog is already open");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(message),
      // scrollable: true,
      content: Container(
          constraints: BoxConstraints(maxHeight: 230, maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "github地址:  ", style: theme.textTheme.bodySmall),
                    TextSpan(text: Constants.githubUrl, style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "使用说明:  ", style: theme.textTheme.bodySmall),
                    TextSpan(text: Constants.userGuideUrl, style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "版本:  ", style: theme.textTheme.bodySmall),
                    TextSpan(text: AppInfo.getAppVersion(), style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ],
          ))),
      actions: [
        TextButton(
          onPressed: () async {
            if (context.mounted) Navigator.pop(context);
          },
          child: Text("返回"),
        ),
        TextButton(
          onPressed: () async {
            if(!await Utils.jumpUrl(Constants.githubUrl)){
              if (context.mounted) Utils.showMessage(context, "无法打开浏览器");
            }
          },
          child: Text("github"),
        ),
        TextButton(
          onPressed: () async {
            if(!await Utils.jumpUrl(Constants.userGuideUrl)){
              if (context.mounted) Utils.showMessage(context, "无法打开浏览器");
            }
          },
          child: Text("使用说明"),
        ),
      ],
    );
  }
}