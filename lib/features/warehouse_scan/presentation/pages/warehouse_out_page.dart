// lib/features/warehouse_scan/presentation/pages/warehouse_out_page.dart
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
import '../bloc/warehouse_out/warehouse_out_bloc.dart';
import '../bloc/warehouse_out/warehouse_out_event.dart';
import '../bloc/warehouse_out/warehouse_out_state.dart';
import '../widgets/qr_scanner_widget.dart';
import '../widgets/warehouse_out_widgets.dart';

class WarehouseOutPage extends StatefulWidget {
  final UserEntity user;

  const WarehouseOutPage({super.key, required this.user});

  @override
  State<WarehouseOutPage> createState() => _WarehouseOutPageState();
}

class _WarehouseOutPageState extends State<WarehouseOutPage> with WidgetsBindingObserver {
  MobileScannerController? _controller;
  final FocusNode _focusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _cameraActive = false; // Camera mặc định tắt
  bool _torchEnabled = false;
  double _maxQuantity = 0;
  String _currentCode = '';
  String _currentMaterialName = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.requestFocus();
    
    // Initialize hardware scanner
    ScanService.initializeScannerListener((scannedData) {
      debugPrint("QR DEBUG: Hardware scanner callback with data: $scannedData");
      if (mounted) {
        context.read<WarehouseOutBloc>().add(HardwareScanEvent(scannedData));
      }
    });
    
    _initializeCameraController();
  }

  @override
  void dispose() {
    _cleanUpCamera();
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _quantityController.dispose();
    _addressController.dispose();
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
      context.read<WarehouseOutBloc>().add(InitializeScanner(_controller!));
      
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
    setState(() {
      _resetForm();
    });
    context.read<WarehouseOutBloc>().add(ClearScannedData());
  }

  void _validateQuantity(String value) {
    if (mounted) {
      context.read<WarehouseOutBloc>().add(
        ValidateQuantityEvent(
          quantity: value,
          maxQuantity: _maxQuantity,
        ),
      );
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ConfirmationDialog.show(
        context,
        onConfirm: () {
          // Submit form data
          context.read<WarehouseOutBloc>().add(
            ProcessWarehouseOutEvent(
              code: _currentCode,
              address: _addressController.text,
              quantity: double.tryParse(_quantityController.text) ?? 0,
            ),
          );
        },
        onCancel: () {
          Navigator.of(context).pop(); // Close the dialog
        },
      );
    }
  }

  void _resetForm() {
    _quantityController.clear();
    _addressController.clear();
    _currentCode = '';
    _currentMaterialName = '';
    _maxQuantity = 0;
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
        context.read<WarehouseOutBloc>().add(ScanBarcode(rawValue));
      }

      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WarehouseOutBloc, WarehouseOutState>(
      listener: (context, state) {
        if (state is WarehouseOutProcessing) {
          LoadingDialog.show(context);
        } else if (state is MaterialInfoLoaded) {
          // Hide loading dialog
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          // Update local state for form
          setState(() {
            _currentCode = state.material.code;
            _currentMaterialName = state.material.mName;
            _maxQuantity = state.material.mQty;
          });
          
        } else if (state is WarehouseOutProcessingRequest) {
          LoadingDialog.show(context);
        } else if (state is WarehouseOutSuccess) {
          // Hide loading dialog
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          // Show success message
          SuccessOutDialog.show(
            context,
            onDismiss: () {
              // Reset form
              _resetForm();
              // Clear scanned data
              context.read<WarehouseOutBloc>().add(ClearScannedData());
            }
          );
        } else if (state is WarehouseOutError) {
          // Hide loading dialog
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          
          // Show error message using ErrorDialog
          ErrorDialog.show(
            context,
            title: 'Error',
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        return CustomScaffold(
          title: 'EXPORT PAGE',
          user: widget.user,
          currentIndex: 1,
          // Add camera control buttons to the AppBar
          actions: [
            IconButton(
              icon: Icon(
                _torchEnabled ? Icons.flash_on : Icons.flash_off,
                color: _torchEnabled ? Colors.yellow : Colors.white,
              ),
              onPressed: _toggleTorch,
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios, color: Colors.white),
              onPressed: _switchCamera,
            ),
            IconButton(
              icon: Icon(
                _cameraActive ? Icons.stop : Icons.play_arrow,
                color: _cameraActive ? Colors.red : Colors.white,
              ),
              onPressed: _toggleCamera,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _clearData,
            ),
          ],
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

                // Material Info and Form
                Expanded(
                  child:  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Table-like layout for info
                          _buildInfoTable(),
                        ],
                      ),
                    ),
                  ),
                ),

                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFFAF1E6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        spacing: 5,
        children: [
          _buildTableRow('ID', _currentCode),
          _buildDivider(),
          _buildTableRow('Material Name', _currentMaterialName),
          _buildDivider(),
          _buildQuantityRow(),
          _buildDivider(),
          _buildAddressRow(),
        ],
      ),
    );
  }
  
  Widget _buildTableRow(String label, String value) {
    return Row(
      children: [
        Container(
          height: 70,
          width: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        // Value side (right)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              value.isEmpty ? 'No Scan data' : value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: value.isEmpty ? Colors.black : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildQuantityRow() {
    return Row(
      children: [
        Container(
          height: 72,
          width: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Quantity',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        // Value side with text field
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextFormField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                helperText: _maxQuantity > 0 ? 'Max: $_maxQuantity' : null,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                final quantity = double.tryParse(value);
                if (quantity == null) {
                  return 'Please enter a valid number';
                }
                if (quantity <= 0) {
                  return 'Quantity must be greater than 0';
                }
                if (quantity > _maxQuantity) {
                  return 'Quantity invalid';
                }
                return null;
              },
              onChanged: _validateQuantity,
              enabled: _currentCode.isNotEmpty,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAddressRow() {
    return Row(
      children: [
        Container(
          height: 70,
          width: 72,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(5),
            ),
          ),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Address',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
        // Value side with text field
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: _addressController,
              keyboardType: TextInputType.text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                // Validate no special characters
                if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                  return 'No special characters allowed';
                }
                return null;
              },
              enabled: _currentCode.isNotEmpty,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDivider() {
    return const SizedBox(height: 2);
  }
}