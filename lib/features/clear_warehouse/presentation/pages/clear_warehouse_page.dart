import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/core/constants/key_code_constants.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
import 'package:warehouse_scan/core/services/get_translate_key.dart';
import 'package:warehouse_scan/core/widgets/confirmation_dialog.dart';
import 'package:warehouse_scan/core/widgets/error_dialog.dart';
import 'package:warehouse_scan/core/widgets/loading_dialog.dart';
import 'package:warehouse_scan/core/widgets/notification_dialog.dart';
import 'package:warehouse_scan/core/widgets/scafford_custom.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import 'package:warehouse_scan/features/warehouse_scan/data/datasources/scan_service_impl.dart';
import 'package:warehouse_scan/features/warehouse_scan/presentation/widgets/qr_scanner_widget.dart';
import '../../domain/entities/clear_warehouse_item_entity.dart';
import '../bloc/clear_warehouse_bloc.dart';
import '../bloc/clear_warehouse_event.dart';
import '../bloc/clear_warehouse_state.dart';
import '../view_models/warehouse_item_view_model.dart';
import '../widgets/warehouse_item_info_widget.dart';

class ClearWarehousePage extends StatefulWidget {
  final UserEntity user;

  const ClearWarehousePage({super.key, required this.user});

  @override
  State<ClearWarehousePage> createState() => _ClearWarehousePageState();
}

class _ClearWarehousePageState extends State<ClearWarehousePage>
    with WidgetsBindingObserver {
  MobileScannerController? _controller;
  final FocusNode _focusNode = FocusNode();

  bool _cameraActive = false;
  bool _torchEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.requestFocus();

    ScanService.initializeScannerListener((scannedData) {
      if (mounted) {
        context.read<ClearWarehouseBloc>().add(HardwareScanEvent(scannedData));
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
    } else if (state == AppLifecycleState.resumed && _cameraActive) {
      _initializeCameraController();
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

      context.read<ClearWarehouseBloc>().add(InitializeScanner(_controller!));

      if (!_cameraActive && _controller != null) {
        _controller!.stop();
      }
    } catch (e) {
      ErrorDialog.show(
        context,
        title: context.multiLanguage.errorUPCASE,
        message: context.multiLanguage.cannotAccessCameraWithoutParam,
      );
    }
  }

  void _cleanUpCamera() {
    if (_controller != null) {
      try {
        _controller?.stop();
        _controller?.dispose();
      } catch (e) {
        debugPrint("QR DEBUG: Error disposing camera: $e");
      }
      _controller = null;
    }
  }

  void _toggleCamera() {
    setState(() {
      _cameraActive = !_cameraActive;

      if (_cameraActive) {
        ScanService.disposeScannerListener();

        try {
          if (_controller == null) {
            _initializeCameraController();
          }
          _controller!.start();
        } catch (e) {
          _cleanUpCamera();
          _initializeCameraController();
          _controller?.start();
        }
      } else if (_controller != null) {
        _controller?.stop();

        ScanService.initializeScannerListener((scannedData) {
          if (mounted) {
            context.read<ClearWarehouseBloc>().add(
              HardwareScanEvent(scannedData),
            );
          }
        });
      }
    });
  }

  Future<void> _toggleTorch() async {
    if (_controller != null && _cameraActive) {
      await _controller!.toggleTorch();
      setState(() {
        _torchEnabled = !_torchEnabled;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_controller != null && _cameraActive) {
      await _controller!.switchCamera();
    }
  }

  void _clearWarehouseQuantity(String code) {
    ConfirmationDialog.show(
      context,
      title: context.multiLanguage.confirmationUPCASE,
      message: context.multiLanguage.clearWarehouseQuantityMessage,
      confirmText: context.multiLanguage.clearButton,
      cancelText: context.multiLanguage.cancelButton,
      confirmColor: Colors.red,
      onConfirm: () {
        context.read<ClearWarehouseBloc>().add(ClearWarehouseQuantityEvent(code));
      },
      onCancel: () {},
    );
  }

  void _clearAllItems() {
    ConfirmationDialog.show(
      context,
      title: context.multiLanguage.clearDataTitleUPCASE,
      message: context.multiLanguage.clearDataMessage,
      confirmText: context.multiLanguage.clearButton,
      cancelText: context.multiLanguage.cancelButton,
      confirmColor: Colors.red,
      onConfirm: () {
        context.read<ClearWarehouseBloc>().add(ClearAllWarehouseItemsEvent());
      },
      onCancel: () {},
    );
  }

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;

      if (rawValue == null || rawValue.isEmpty) continue;

      if (mounted) {
        context.read<ClearWarehouseBloc>().add(ScanWarehouseItem(rawValue));
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final rowHeight = screenHeight * 0.07;

    return BlocConsumer<ClearWarehouseBloc, ClearWarehouseState>(
      listener: (context, state) {
        switch (state) {
          case ClearWarehouseClearing():
            LoadingDialog.show(context);
            break;

          case ClearWarehouseClearSuccess():
            LoadingDialog.hide(context);
            
            NotificationDialog.show(
              context,
              title: context.multiLanguage.successUPCASE,
              message: context.multiLanguage.clearWarehouseSuccessMessage,
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            );
            break;

          case ClearWarehouseError(:final message, :final args):
            LoadingDialog.hide(context);
            
            ErrorDialog.show(
              context,
              title: context.multiLanguage.errorUPCASE,
              message: TranslateKey.getStringKey(
                context.multiLanguage,
                message,
                args: args,
              ),
            );
            break;
        }
      },
      builder: (context, state) {
        final items = _getScannedItems(state);
        final mainItem = items.isNotEmpty ? items.first : WarehouseItemViewModel.empty();

        
        return CustomScaffold(
          title: context.multiLanguage.clearWarehousePageTitle,
          user: widget.user,
          showHomeIcon: true,
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
              onPressed: _clearAllItems,
            ),
          ],
          body: KeyboardListener(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: (KeyEvent event) {
              if (event is KeyDownEvent) {
                if (KeycodeConstants.scannerKeyCodes.contains(
                      event.logicalKey.keyId,
                    ) ||
                    ScanService.isScannerButtonPressed(event)) {
                  debugPrint("Scanner key pressed");
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
                WarehouseItemInfoWidget(
                  viewModel: mainItem,
                  onRemovePressed: items.isNotEmpty
                      ? () {
                          context.read<ClearWarehouseBloc>().add(
                            RemoveFromWarehouseList(mainItem.itemCode),
                          );
                        }
                      : null,
                ),
                SizedBox(
                    width: 100,
                    height: rowHeight,
                    child: ElevatedButton(
                      onPressed: () => _clearWarehouseQuantity(items.first.itemCode),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        context.multiLanguage.clearButton,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<WarehouseItemViewModel> _getScannedItems(ClearWarehouseState state) {
    List<ClearWarehouseItemEntity> entities = [];
    switch (state) {
      case ClearWarehouseScanning(:final scannedItems):
      case ClearWarehouseProcessing(:final scannedItems):
      case ClearWarehouseItemChecked(:final scannedItems):
      case ClearWarehouseListUpdated(:final scannedItems):
      case ClearWarehouseClearing(:final scannedItems):
        entities = scannedItems;
        break;
      case ClearWarehouseClearSuccess(:final remainingItems):
        entities = remainingItems;
        break;
      default:
        entities = [];
    }
    return entities.map((e) => WarehouseItemViewModel.fromEntity(e)).toList();
  }
}