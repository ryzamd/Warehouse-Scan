import 'package:flutter/material.dart';

import '../constants/enum.dart';

class DialogUtils {
  static DialogTypes? _currentDialogType;
  static BuildContext? _currentDialogContext;
  
  static bool prepareForDialog(BuildContext context, DialogTypes dialogType) {
    if (_currentDialogType == dialogType) {
      return false;
    }
    
    if (_currentDialogType != null && _currentDialogContext != null && _currentDialogContext!.mounted) {
      try {
        if (Navigator.canPop(_currentDialogContext!)) {
          Navigator.of(_currentDialogContext!, rootNavigator: true).pop();
        }
      } catch (e) {
        debugPrint('Error dismissing dialog: $e');
      }
    }
    
    _currentDialogType = dialogType;
    _currentDialogContext = context;
    return true;
  }
  
  static void dialogDismissed(DialogTypes dialogType) {
    if (_currentDialogType == dialogType) {
      _currentDialogType = null;
      _currentDialogContext = null;
    }
  }

  static bool isDialogShowing(DialogTypes dialogType) {
    return _currentDialogType == dialogType;
  }
}