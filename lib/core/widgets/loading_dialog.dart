import 'package:flutter/material.dart';
import 'package:warehouse_scan/core/constants/enum.dart';

import '../utils/dialog_utils.dart';

class LoadingDialog extends StatelessWidget {
  const LoadingDialog({
    super.key,
  });
  
  static void show(BuildContext context) {
     if (!context.mounted) return;
    
    if (DialogUtils.prepareForDialog(context, DialogTypes.loading)) {
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoadingDialog(),
      ).then((_) {
        DialogUtils.dialogDismissed(DialogTypes.loading);
      });
    }
  }
  
  static void hide(BuildContext context) {
    if (DialogUtils.isDialogShowing(DialogTypes.loading) && context.mounted) {
      Navigator.of(context).pop();
      DialogUtils.dialogDismissed(DialogTypes.loading);
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