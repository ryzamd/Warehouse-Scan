// lib/features/warehouse_scan/data/datasources/scan_service_impl.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScanService {
  static const EventChannel _eventChannel = EventChannel('com.example.warehouse_scan/scanner');
  static const MethodChannel _methodChannel = MethodChannel('com.example.warehouse_scan');
  
  static Function(String)? onBarcodeScanned;
  static final List<String> scannedBarcodes = [];
  static StreamSubscription? _subscription;
  static Timer? _debounceTimer;
  static bool _isInitialized = false;

  static void initializeScannerListener(Function(String) onScanned) {
    if (_isInitialized) {
      disposeScannerListener();
    }
    
    _isInitialized = true;
    onBarcodeScanned = onScanned;
    
    debugPrint("QR DEBUG: Initializing hardware scanner event channel");
    
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic scanData) {
        debugPrint("QR DEBUG: 📟 Hardware scanner data received: $scanData");
        if (scanData != null && scanData.toString().isNotEmpty) {
          if (_debounceTimer?.isActive ?? false) {
            debugPrint("QR DEBUG: Debouncing rapid scan");
            return;
          }
          
          _debounceTimer = Timer(const Duration(milliseconds: 500), () {});
          onBarcodeScanned?.call(scanData.toString());
          
          if (!scannedBarcodes.contains(scanData.toString())) {
            scannedBarcodes.add(scanData.toString());
          }
        }
      },
      onError: (dynamic error) {
        debugPrint("QR DEBUG: ❌ Hardware scanner error: $error");
      }
    );
    
    _methodChannel.setMethodCallHandler((MethodCall call) async {
      debugPrint("QR DEBUG: Method channel called: ${call.method}");
      if (call.method == "scannerKeyPressed") {
        String scannedData = call.arguments.toString();
        debugPrint("QR DEBUG: Scanner key pressed: $scannedData");
        
        if (_debounceTimer?.isActive ?? false) {
          debugPrint("QR DEBUG: Debouncing rapid scan");
          return null;
        }
        
        _debounceTimer = Timer(const Duration(milliseconds: 500), () {});
        onBarcodeScanned?.call(scannedData);
      }
      return null;
    });
    
    debugPrint("QR DEBUG: Hardware scanner initialized");
    
    try {
      _methodChannel.invokeMethod('testScanEvent');
    } catch (e) {
      debugPrint("QR DEBUG: Error invoking test method: $e");
    }
  }
  
  static void disposeScannerListener() {
    _subscription?.cancel();
    _subscription = null;
    onBarcodeScanned = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _isInitialized = false;
    debugPrint("QR DEBUG: Scanner listener disposed");
  }

  static bool isScannerButtonPressed(KeyEvent event) {
    const scannerKeyCodes = [120, 121, 122, 293, 294, 73014444552];
    final isScanner = scannerKeyCodes.contains(event.logicalKey.keyId);
    if (isScanner) {
      debugPrint("QR DEBUG: Hardware scanner key detected: ${event.logicalKey.keyId}");
    }
    return isScanner;
  }
  
  static void clearScannedBarcodes() {
    scannedBarcodes.clear();
    debugPrint("QR DEBUG: Scanned barcodes history cleared");
  }
}