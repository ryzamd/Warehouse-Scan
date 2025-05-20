import 'package:flutter/material.dart';

import '../constants/enum.dart';
import '../utils/dialog_utils.dart';

class NotificationDialog extends StatelessWidget {
  static bool isShowing = false;
  
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

    if (!context.mounted) return;

    if (DialogUtils.prepareForDialog(context, DialogTypes.notification)) {
      
    isShowing = true;
    
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
      isShowing = false;
      DialogUtils.dialogDismissed(DialogTypes.notification);
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
            isShowing = false;
            Navigator.pop(context);
            if (onDismiss != null && context.mounted) {
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