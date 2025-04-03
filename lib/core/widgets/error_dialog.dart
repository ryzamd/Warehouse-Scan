// lib/core/widgets/error_dialog.dart
import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;
  
  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDismiss,
  });
  
  // Show error dialog
  static void show(
    BuildContext context, {
    String title = 'Error',
    String message = 'An error occurred.',
    VoidCallback? onDismiss,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        title: title,
        message: message,
        onDismiss: onDismiss ?? () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.red,
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