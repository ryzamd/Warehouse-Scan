// lib/core/widgets/loading_dialog.dart
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  
  const LoadingDialog({
    super.key,
  });
  
  // Show loading dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(),
    );
  }
  
  // Hide loading dialog
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const SizedBox(
        height: 100,
        width: 100,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ),
    );
  }
}