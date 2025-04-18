import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      title: const Text(
        'EXIT',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: const Text('Are you sure to exit the application?'),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(fontSize: 14)),
        ),
        TextButton(
          onPressed: () => SystemNavigator.pop(),
          child: const Text('OK', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }
}