// lib/features/warehouse_scan/presentation/widgets/warehouse_out_widgets.dart
import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  static bool _isShowing = false;
  
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmationDialog({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });
  
  // Add a static show method for consistency
  static void show(
    BuildContext context, {
    required VoidCallback onConfirm,
    required VoidCallback onCancel,
  }) {
    // Only show if no dialog is currently visible
    if (!_isShowing && context.mounted) {
      _isShowing = true;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ConfirmationDialog(
          onConfirm: () {
            _isShowing = false;
            onConfirm();
          },
          onCancel: () {
            _isShowing = false;
            onCancel();
          },
        ),
      ).then((_) {
        // Ensure flag is reset when dialog is dismissed
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
        'Confirmation',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: const Text(
        'Are you sure you want to process this warehouse-out request?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            onCancel();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
          ),
          child: const Text(
            'Confirm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class SuccessOutDialog extends StatelessWidget {
  static bool _isShowing = false;
  
  final VoidCallback onDismiss;

  const SuccessOutDialog({
    super.key,
    required this.onDismiss,
  });

  static void show(BuildContext context, {required VoidCallback onDismiss}) {
    // Only show if no dialog is currently visible
    if (!_isShowing && context.mounted) {
      _isShowing = true;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SuccessOutDialog(onDismiss: onDismiss),
      ).then((_) {
        // Ensure flag is reset when dialog is dismissed
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
          const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Success',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'The material has been successfully sent for warehouse-out processing.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _isShowing = false;
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