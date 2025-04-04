// lib/features/warehouse_scan/presentation/widgets/warehouse_in_widgets.dart
import 'package:flutter/material.dart';

class SuccessImportDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const SuccessImportDialog({
    super.key,
    required this.onDismiss,
  });

  static void show(BuildContext context, {required VoidCallback onDismiss}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessImportDialog(onDismiss: onDismiss),
    );
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
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Import successfully',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The material has been successfully imported to the warehouse.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onDismiss();
          },
          child: const Text(
            'OK',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}