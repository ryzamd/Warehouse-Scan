// lib/core/widgets/error_dialog.dart
import 'package:flutter/material.dart';

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
  
  // Show error dialog
  static void show(
    BuildContext context, {
    String title = 'Error',
    String message = 'An error occurred.',
    VoidCallback? onDismiss,
  }) {
    // Kiểm tra context có valid không trước khi hiển thị dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => ErrorDialog(
          title: title,
          message: message,
          onDismiss: onDismiss,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Ngăn việc back bằng nút back của hệ thống nếu không có xử lý
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && onDismiss != null) {
          onDismiss!();
        }
      },
      child: AlertDialog(
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
              // Đơn giản hóa logic - chỉ pop dialog trong mọi trường hợp
              Navigator.of(context).pop();
              // Gọi callback sau khi đã pop dialog
              if (onDismiss != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  onDismiss!();
                });
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}