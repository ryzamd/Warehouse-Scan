// lib/core/widgets/loading_dialog.dart
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  static bool _isShowing = false;
  
  const LoadingDialog({
    super.key,
  });
  
  // Show loading dialog
  static void show(BuildContext context) {
    // Only show if no loading dialog is already visible
    if (!_isShowing && context.mounted) {
      _isShowing = true;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingDialog(),
      ).then((_) {
        // Ensure flag is reset when dialog is dismissed
        _isShowing = false;
      });
    }
  }
  
  // Hide loading dialog
  static void hide(BuildContext context) {
    if (_isShowing && context.mounted) {
      Navigator.of(context).pop();
      _isShowing = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const SizedBox(
        height: 150,
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