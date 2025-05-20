import 'package:flutter/material.dart';

import '../constants/enum.dart';
import '../utils/dialog_utils.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final Color confirmColor;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    required this.onConfirm,
    required this.onCancel,
    this.confirmColor = Colors.green,
  });
  
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
    Color confirmColor = Colors.green,
  }) {
     if (!context.mounted) return;
    
    if (DialogUtils.prepareForDialog(context, DialogTypes.confirmation)) {
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ConfirmationDialog(
          title: title,
          message: message,
          confirmText: confirmText,
          cancelText: cancelText,
          onConfirm: () {
            Navigator.pop(context);
            onConfirm();
          },
          onCancel: () {
            Navigator.pop(context);
            onCancel();
          },
          confirmColor: confirmColor,
        ),
      ).then((_) {
        DialogUtils.dialogDismissed(DialogTypes.confirmation);
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
          fontWeight: FontWeight.bold,
          color: Colors.redAccent,
          fontSize: 18,
        ),
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            onCancel();
          },
          child: Text(
            cancelText,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: confirmColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          child: Text(
            confirmText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}