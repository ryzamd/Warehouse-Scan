import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/exit_confirmation_dialog.dart';

class BackButtonService {

  static final BackButtonService _instance = BackButtonService._internal();
  factory BackButtonService() => _instance;
  BackButtonService._internal();


  static const EventChannel _eventChannel = EventChannel(
    'com.example.warehouse_scan/back_button',
  );

  // Stream subscription để lắng nghe sự kiện
  StreamSubscription? _subscription;

  // Khởi tạo service và lắng nghe sự kiện back button
  void initialize(BuildContext context) {
    _subscription?.cancel();
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (_) {
        if (context.mounted) {
          ExitConfirmationDialog.show(context);
        }
      },
    );
  }

  // Dọn dẹp resource khi không cần thiết
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
