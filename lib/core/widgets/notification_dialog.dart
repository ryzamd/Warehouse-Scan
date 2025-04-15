import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  static bool _isShowing = false;
  
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback? onDismiss;
  final IconData icon;
  final Color iconColor;
  
  const NotificationDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
    this.onDismiss,
    this.icon = Icons.notifications,
    this.iconColor = Colors.blue,
  });
  
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onDismiss,
    IconData icon = Icons.notifications,
    Color iconColor = Colors.blue,
  }) {

    if (!_isShowing && context.mounted) {
      _isShowing = true;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => NotificationDialog(
          title: title,
          message: message,
          buttonText: buttonText,
          onDismiss: onDismiss,
          icon: icon,
          iconColor: iconColor,
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _isShowing = false;
            Navigator.pop(context);
            if (onDismiss != null) {
              onDismiss!();
            }
          },
          child: Text(
            buttonText,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
          ),
        ),
      ],
    );
  }
}