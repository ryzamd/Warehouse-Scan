import 'package:flutter/material.dart';
import 'package:warehouse_scan/core/constants/enum.dart';

import '../utils/dialog_utils.dart';

class SuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;
  
  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDismiss,
  });
  
  static void show(
    BuildContext context, {
    String title = 'Success',
    String message = 'Operation completed successfully.',
    VoidCallback? onDismiss,
  }) {
    if (!context.mounted) return;
    
    if (DialogUtils.prepareForDialog(context, DialogTypes.success)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => SuccessDialog(
          title: title,
          message: message,
          onDismiss: onDismiss ?? () {
            Navigator.of(context).pop();
          },
        ),
      ).then((_) {
        DialogUtils.dialogDismissed(DialogTypes.success);
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
        title,
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}