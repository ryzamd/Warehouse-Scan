import 'package:flutter/material.dart';

import '../constants/enum.dart';
import '../utils/dialog_utils.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onDismiss;
  
  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.onDismiss,
  });

  static void show(
    BuildContext context, {
    String title = 'Error',
    String message = 'An error occurred.',
    VoidCallback? onDismiss,
  }) {
     if (!context.mounted) return;
    
    if (DialogUtils.prepareForDialog(context, DialogTypes.error)) {
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => ErrorDialog(
          title: title,
          message: message,
          onDismiss: onDismiss,
        ),
      ).then((_) {
        DialogUtils.dialogDismissed(DialogTypes.error);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && onDismiss != null) {
          onDismiss!();
        }
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onDismiss != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onDismiss!();
                });
              }
            },
            child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}