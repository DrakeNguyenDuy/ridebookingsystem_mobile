import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HandleMessage {
  void showToast(BuildContext context, String? message, String? lable) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(
      content: Text(message!),
      action: SnackBarAction(
        label: lable!,
        onPressed: () => scaffold.hideCurrentMaterialBanner(),
      ),
    ));
  }
}
