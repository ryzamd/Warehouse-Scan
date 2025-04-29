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
import '../../../../core/di/dependencies.dart' as di;
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/notification_dialog.dart';
import '../../../address/presentation/bloc/address_bloc.dart';
import '../../../address/presentation/widgets/address_selector.dart';
import '../bloc/warehouse_out/warehouse_out_bloc.dart';
import '../bloc/warehouse_out/warehouse_out_event.dart';
import '../bloc/warehouse_out/warehouse_out_state.dart';
import '../widgets/qr_scanner_widget.dart';


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
  
  bool _cameraActive = false;
  bool _torchEnabled = false;
  double _maxQuantity = 0;
  String _currentCode = '';
  String _currentMaterialName = '';
  double _warehouseQtyImport = 0.0;
  double _warehouseQtyExport = 0.0;
  int _optionFunction = 2;
  

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.requestFocus();
    
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
        formats: const [BarcodeFormat.qrCode, BarcodeFormat.code128],
        detectionSpeed: DetectionSpeed.normal,
        detectionTimeoutMs: 1000,
        facing: CameraFacing.back,
        returnImage: false,
        torchEnabled: _torchEnabled,
      );

      context.read<WarehouseOutBloc>().add(InitializeScanner(_controller!));
      
      if (!_cameraActive && _controller != null) {
        _controller!.stop();
      }
    } catch (e) {
      debugPrint("QR DEBUG: ⚠️ Camera initialization error: $e");
      ErrorDialog.show(
        context,
        title: 'CAMERA ERROR',
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
        title: 'CONFIRMATION',
        message: 'Are you sure you want to process this warehouse-out request?',
        confirmColor: Colors.redAccent,
        onConfirm: () {
          context.read<WarehouseOutBloc>().add(
            ProcessWarehouseOutEvent(
              code: _currentCode,
              address: _addressController.text,
              quantity: double.tryParse(_quantityController.text) ?? 0,
              optionFunction: _optionFunction,
            ),
          );
        },
        onCancel: () {},
      );
    }
  }

  void _resetForm() {
    _quantityController.clear();
    _addressController.clear();
    _currentCode = '';
    _currentMaterialName = '';
    _maxQuantity = 0;
    _warehouseQtyImport = 0.0;
    _warehouseQtyExport = 0.0;
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
        var navigatorContext = Navigator.of(context);
        
        switch (state) {
          case WarehouseOutProcessing():
          case WarehouseOutProcessingRequest():
            LoadingDialog.show(context);
            break;
            
          case MaterialInfoLoaded():
            if (LoadingDialog.isShowing && navigatorContext.canPop()) {
              navigatorContext.pop();
            }
            
            if (_currentCode != state.material.code) {
              setState(() {
                _currentCode = state.material.code;
                _currentMaterialName = state.material.mName;
                _maxQuantity = state.material.mQty;
                _warehouseQtyImport = state.material.zcWarehouseQtyImport;
                _warehouseQtyExport = state.material.zcWarehouseQtyExport;
              });
            }
            break;
            
          case WarehouseOutSuccess():
            if (navigatorContext.canPop()) {
              navigatorContext.pop();
            }
            
            NotificationDialog.show(
              context,
              title: 'SUCCESS',
              message: 'The material has been successfully sent for warehouse-out processing.',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
              onDismiss: () {
                _resetForm();
                context.read<WarehouseOutBloc>().add(ClearScannedData());
              }
            );
            break;
            
          case WarehouseOutError():
            if (navigatorContext.canPop()) {
              navigatorContext.pop();
            }
            
            ErrorDialog.show(
              context,
              title: 'ERROR',
              message: state.message,
            );
            break;
        }
      },
      builder: (context, state) {
        return CustomScaffold(
          title: 'EXPORT PAGE',
          showHomeIcon: true,
          user: widget.user,
          currentIndex: 1,
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
              onPressed: () {
                  ConfirmationDialog.show(
                  context,
                  title: 'CLEAR DATA',
                  message: 'Are you sure you want to clear all data?',
                  confirmColor: Colors.redAccent,
                  onConfirm: _clearData,
                  onCancel: () {},
                );
              }
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
                Container(
                  margin: const EdgeInsets.all(5),
                  child: QRScannerWidget(
                    controller: _controller,
                    onDetect: _onDetect,
                    isActive: _cameraActive,
                    onToggle: _toggleCamera,
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Form(
                      key: _formKey,
                      child: _buildInfoTable(),
                    ),
                  ),
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Center(
                      child: MediaQuery.of(context).viewInsets.bottom > 0
                        ? const SizedBox.shrink()
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
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
                                '保存',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                                ),
                              ),
                            ),

                            ElevatedButton(
                              onPressed: () {
                                if(_currentCode.isNotEmpty && _optionFunction == 1){
                                  setState(() {
                                    _optionFunction = 1;
                                  });
                                  
                                  ErrorDialog.show(
                                    context,
                                    title: 'ERROR',
                                    message: 'You must clear data first to switch functionality !',
                                  );
                                }else{
                                  setState(() {
                                    _optionFunction = _optionFunction == 2 ? 1 : 2;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _optionFunction == 2 ? Colors.red : Colors.green.shade600,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                      _optionFunction == 2 ? '减少' : '增加',
                                      style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                      ),
                                    ),
                            )
                          ],
                        ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildInfoTable() {
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight * 0.62;
    
    final normalRowHeight = availableHeight * 0.15;
    
    return Container(
      constraints: BoxConstraints(
        minHeight: availableHeight,
        maxHeight: availableHeight,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xFFFAF1E6),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTableRow('名稱', _currentMaterialName, height: normalRowHeight),
                _buildDivider(),
                _buildTableRow('入庫數量', _warehouseQtyImport.toString(), height: normalRowHeight),
                _buildDivider(),
                _buildTableRow('出庫數量', _warehouseQtyExport.toString(), height: normalRowHeight),
                _buildDivider(),
                _buildQuantityRow(height: normalRowHeight),
                _buildDivider(),
                _buildAddressRow(height: normalRowHeight),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildTableRow(String label, String value, {required double height}) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Container(
            width: 74,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                fontSize: 12,
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
      ),
    );
}
  
  Widget _buildQuantityRow({required double height}) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Container(
            width: 74,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: const Text(
              '輸入數據',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ValueListenableBuilder(
                valueListenable: _quantityController,
                builder: (context, value, child){
                  return TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                       enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: value.text.isNotEmpty ? Colors.grey.shade600 : Colors.grey.shade400,
                          width: value.text.isNotEmpty ? 2.0 : 1.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                  );
                },
              )
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressRow({required double height}) {
    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 74,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                bottomLeft: Radius.circular(5),
              ),
            ),
            alignment: Alignment.centerLeft,
            child: const Text(
              '收貨方',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: BlocProvider(
                create: (context) => di.sl<AddressBloc>(),
                child: AddressSelector(
                  currentAddress: _addressController.text,
                  onAddressSelected: (address) {
                    setState(() {
                      _addressController.text = address;
                    });
                  },
                  enabled: _currentCode.isNotEmpty && _optionFunction == 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const SizedBox(height: 2);
  }
}