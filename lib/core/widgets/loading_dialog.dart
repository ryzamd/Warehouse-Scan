import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  static bool _isShowing = false;
  
  const LoadingDialog({
    super.key,
  });
  
  static void show(BuildContext context) {
    if (!_isShowing && context.mounted) {
      _isShowing = true;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingDialog(),
      ).then((_) {
        _isShowing = false;
      });
    }
  }
  
  static void hide(BuildContext context) {
    if (_isShowing && context.mounted) {
      Navigator.of(context).pop();
      _isShowing = false;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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