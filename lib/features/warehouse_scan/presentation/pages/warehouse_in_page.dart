// lib/features/warehouse_scan/presentation/pages/warehouse_in_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/core/constants/key_code_constants.dart';
import 'package:warehouse_scan/core/widgets/error_dialog.dart';
import 'package:warehouse_scan/core/widgets/loading_dialog.dart';
import 'package:warehouse_scan/core/widgets/scafford_custom.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import 'package:warehouse_scan/features/warehouse_scan/data/datasources/scan_service_impl.dart';
import '../bloc/warehouse_in/warehouse_in_bloc.dart';
import '../bloc/warehouse_in/warehouse_in_event.dart';
import '../bloc/warehouse_in/warehouse_in_state.dart';
import '../widgets/qr_scanner_widget.dart';
import '../widgets/warehouse_in_widgets.dart';

class WarehouseInPage extends StatefulWidget {
  final UserEntity user;

  const WarehouseInPage({super.key, required this.user});

  @override
  State<WarehouseInPage> createState() => _WarehouseInPageState();
}

class _WarehouseInPageState extends State<WarehouseInPage> with WidgetsBindingObserver {
  MobileScannerController? _controller;
  final FocusNode _focusNode = FocusNode();
  
  bool _cameraActive = false; // Camera mặc định tắt
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.requestFocus();
    
    // Initialize hardware scanner
    ScanService.initializeScannerListener((scannedData) {
      debugPrint("QR DEBUG: Hardware scanner callback with data: $scannedData");
      if (mounted) {
        context.read<WarehouseInBloc>().add(HardwareScanEvent(scannedData));
      }
    });
    
    _initializeCameraController();
  }

  @override
  void dispose() {
    _cleanUpCamera();
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    ScanService.disposeScannerListener();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _cleanUpCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraActive) {
        _initializeCameraController();
      }
    }
  }

  void _initializeCameraController() {
    _cleanUpCamera();

    try {
      _controller = MobileScannerController(
        formats: const [
          BarcodeFormat.qrCode,
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.ean8,
          BarcodeFormat.ean13,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
          BarcodeFormat.codabar,
        ],
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        returnImage: false,
        torchEnabled: _torchEnabled,
      );

      // Initialize scanner in BLoC
      context.read<WarehouseInBloc>().add(InitializeScanner(_controller!));
      
      // Make sure camera is stopped if _cameraActive is false
      if (!_cameraActive && _controller != null) {
        _controller!.stop();
      }
    } catch (e) {
      debugPrint("QR DEBUG: ⚠️ Camera initialization error: $e");
      ErrorDialog.show(
        context,
        title: 'Camera Error',
        message: "Camera initialization error: $e",
      );
    }
  }

  void _cleanUpCamera() {
    if (_controller != null) {
      try {
        _controller?.stop();
        _controller?.dispose();
      } catch (e) {
        debugPrint("QR DEBUG: ⚠️ Error disposing camera: $e");
      }
      _controller = null;
    }
  }

  void _toggleCamera() {
    debugPrint("QR DEBUG: Toggle camera button pressed");
    setState(() {
      _cameraActive = !_cameraActive;

      if (_cameraActive) {
        try {
          if (_controller == null) {
            _initializeCameraController();
          }
          _controller!.start();
        } catch (e) {
          debugPrint("QR DEBUG: Error starting camera: $e");
          _cleanUpCamera();
          _initializeCameraController();
          _controller?.start();
        }
      } else if (_controller != null) {
        _controller?.stop();
      }
    });
  }

  Future<void> _toggleTorch() async {
    debugPrint("QR DEBUG: Toggle torch button pressed");
    if (_controller != null && _cameraActive) {
      await _controller!.toggleTorch();
      setState(() {
        _torchEnabled = !_torchEnabled;
      });
    }
  }

  Future<void> _switchCamera() async {
    debugPrint("QR DEBUG: Switch camera button pressed");
    if (_controller != null && _cameraActive) {
      await _controller!.switchCamera();
    }
  }

  void _clearData() {
    context.read<WarehouseInBloc>().add(ClearScannedData());
  }

  void _onDetect(BarcodeCapture capture) {
    debugPrint("QR DEBUG: === Barcode detected: ${capture.barcodes.length} ===");

    if (capture.barcodes.isEmpty) {
      debugPrint("QR DEBUG: No barcodes detected in this frame");
      return;
    }

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      final format = barcode.format;

      debugPrint("QR DEBUG: Format: $format");
      debugPrint("QR DEBUG: RawValue: $rawValue");

      if (rawValue == null || rawValue.isEmpty) {
        debugPrint("QR DEBUG: ⚠️ Empty barcode value");
        continue;
      }

      debugPrint("QR DEBUG: ✅ QR value success: $rawValue");

      if (mounted) {
        context.read<WarehouseInBloc>().add(ScanBarcode(rawValue));
      }

      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WarehouseInBloc, WarehouseInState>(
      listener: (context, state) {
        if (state is WarehouseInProcessing) {
          LoadingDialog.show(context);
        } else if (state is WarehouseInSuccess) {
          // Hide loading dialog
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          // Show success message
          SuccessImportDialog.show(context,
            onDismiss: () => _clearData(),
          );
        } else if (state is WarehouseInError) {
          // Hide loading dialog
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          // Show error message using ErrorDialog
          ErrorDialog.show(
            context,
            title: 'ERROR',
            message: state.message,
            onDismiss: () => _clearData(),
          );
        }
      },
      builder: (context, state) {
        return CustomScaffold(
          title: 'IMPORT PAGE',
          user: widget.user,
          currentIndex: 1,
          body: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent) {
                debugPrint("QR DEBUG: Key pressed: ${event.logicalKey.keyId}");
                if (KeycodeConstants.scannerKeyCodes.contains(
                  event.logicalKey.keyId,
                )) {
                  debugPrint("QR DEBUG: Scanner key pressed");
                } else if (ScanService.isScannerButtonPressed(event)) {
                  debugPrint("QR DEBUG: Scanner key pressed via ScanService");
                }
              }
            },
            child: Column(
              children: [
                // QR Camera Section
                Container(
                  margin: const EdgeInsets.all(5),
                  child: QRScannerWidget(
                    controller: _controller,
                    onDetect: _onDetect,
                    isActive: _cameraActive,
                    onToggle: _toggleCamera,
                  ),
                ),

                // App Instructions
                Center(
                  child: const Text(
                    'Scan QR code to process warehouse-in materials',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Empty space
                const Spacer(),
                
                // Camera controls with enhanced visibility
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildEnhancedButton(
                        icon: Icon(
                          _torchEnabled ? Icons.flash_on : Icons.flash_off,
                          color: _torchEnabled ? Colors.yellow : Colors.white,
                          size: 28,
                        ),
                        onPressed: _cameraActive ? _toggleTorch : null,
                        label: 'Flash',
                        color: _torchEnabled ? Colors.amber.shade700 : Colors.blueGrey.shade700,
                      ),
                      const SizedBox(width: 16),
                      _buildEnhancedButton(
                        icon: const Icon(
                          Icons.flip_camera_ios,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _cameraActive ? _switchCamera : null,
                        label: 'Flip',
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 16),
                      _buildEnhancedButton(
                        icon: Icon(
                          _cameraActive ? Icons.stop : Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _toggleCamera,
                        label: _cameraActive ? 'Stop' : 'Start',
                        color: _cameraActive ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Helper method to build enhanced camera control buttons
  Widget _buildEnhancedButton({
    required Widget icon,
    required VoidCallback? onPressed,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(28),
              child: Center(child: icon),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: onPressed == null ? Colors.grey : Colors.black87,
          ),
        ),
      ],
    );
  }
}