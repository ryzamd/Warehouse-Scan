import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';

class ExitConfirmationDialog extends StatelessWidget {
  static bool _isShowing = false;
  
  final VoidCallback? onCancel;
  
  const ExitConfirmationDialog({
    super.key,
    this.onCancel,
  });
  
  static void show(BuildContext context) {
    if (!_isShowing && context.mounted) {
      _isShowing = true;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ExitConfirmationDialog(
          onCancel: () => Navigator.of(context).pop(),
        ),
      ).then((_) {
        _isShowing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        context.multiLanguage.exitDialogLabel,
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Text(context.multiLanguage.exitDialogMessage),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: Text(context.multiLanguage.cancelButton, style: TextStyle(fontSize: 14)),
        ),
        TextButton(
          onPressed: () => SystemNavigator.pop(),
          child: Text(context.multiLanguage.exitDialogConfirmButton, style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}