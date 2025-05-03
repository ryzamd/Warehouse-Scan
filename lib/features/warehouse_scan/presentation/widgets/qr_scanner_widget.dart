import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';

class QRScannerWidget extends StatelessWidget {
  final MobileScannerController? controller;
  final Function(BarcodeCapture)? onDetect;
  final bool isActive;
  final VoidCallback onToggle;
  
  const QRScannerWidget({
    super.key,
    required this.controller,
    required this.onDetect,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("Building QRScannerWidget, camera active: $isActive");
    
    return Stack(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade700, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: isActive && controller != null
              ? MobileScanner(
                  controller: controller!,
                  onDetect: (barcodes) {
                    debugPrint("QR DEBUG: onDetect called from MobileScanner");
                    if (onDetect != null) {
                      onDetect!(barcodes);
                    }
                  },
                  placeholderBuilder: (context, child) {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Text(
                          context.multiLanguage.qrInitializingCameraMessage,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, child) {
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 50),
                            Text(
                              context.multiLanguage.qrCameraErrorMessage(error.errorCode.toString()),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: const WidgetStatePropertyAll(Color(0xFFFF9D23)),
                                shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
                              onPressed: () {
                                controller!.stop();
                                controller!.start();
                              },
                              child: Text(context.multiLanguage.qrTryAgainButton, style: TextStyle(color: Color(0xFFFEF9E1)),),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      context.multiLanguage.qrCameraIsOffStatus,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
          ),
        ),
        
        // QR frame overlay
        if (isActive)
          Positioned.fill(
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                margin: const EdgeInsets.all(5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCorner(true, true),
                        _buildCorner(true, false),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCorner(false, true),
                        _buildCorner(false, false),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
  
  // Function to build a corner for the scanning frame
  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: Colors.redAccent, width: 4) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: Colors.redAccent, width: 4) : BorderSide.none,
          left: isLeft ? const BorderSide(color: Colors.redAccent, width: 4) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: Colors.redAccent, width: 4) : BorderSide.none,
        ),
      ),
    );
  }
}