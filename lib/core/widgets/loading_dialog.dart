// lib/core/widgets/loading_dialog.dart
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  
  const LoadingDialog({
    super.key,
    this.message = 'Loading...',
  });
  
  // Show loading dialog
  static void show(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }
  
  // Hide loading dialog
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }
}