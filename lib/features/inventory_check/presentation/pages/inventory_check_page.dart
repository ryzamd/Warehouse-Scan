import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/core/constants/key_code_constants.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
import 'package:warehouse_scan/core/services/get_translate_key.dart';
import 'package:warehouse_scan/core/widgets/error_dialog.dart';
import 'package:warehouse_scan/core/widgets/loading_dialog.dart';
import 'package:warehouse_scan/core/widgets/notification_dialog.dart';
import 'package:warehouse_scan/core/widgets/scafford_custom.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import 'package:warehouse_scan/features/warehouse_scan/data/datasources/scan_service_impl.dart';
import 'package:warehouse_scan/features/warehouse_scan/presentation/widgets/qr_scanner_widget.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../bloc/inventory_check_bloc.dart';
import '../bloc/inventory_check_event.dart';
import '../bloc/inventory_check_state.dart';
import '../widgets/inventory_item_list.dart';

class InventoryCheckPage extends StatefulWidget {
  final UserEntity user;

  const InventoryCheckPage({super.key, required this.user});

  @override
  State<InventoryCheckPage> createState() => _InventoryCheckPageState();
}

class _InventoryCheckPageState extends State<InventoryCheckPage>
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
        context.read<InventoryCheckBloc>().add(HardwareScanEvent(scannedData));
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

      context.read<InventoryCheckBloc>().add(InitializeScanner(_controller!));

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
            context.read<InventoryCheckBloc>().add(
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

  void _saveInventory() {
    context.read<InventoryCheckBloc>().add(const SaveInventoryListEvent());
  }

  void _clearInventory() {
    context.read<InventoryCheckBloc>().add(ClearInventoryListEvent());
  }

  void _onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;

      if (rawValue == null || rawValue.isEmpty) continue;

      if (mounted) {
        context.read<InventoryCheckBloc>().add(ScanInventoryItem(rawValue));
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InventoryCheckBloc, InventoryCheckState>(
      listener: (context, state) {
        switch (state) {
          case InventorySaving():
            LoadingDialog.show(context);
            break;

           case InventorySaveSuccess(:final inventoriedCount, :final failedCount):
            LoadingDialog.hide(context);
            
            final messages = [
              if (inventoriedCount > 0) context.multiLanguage.successfullyProcessed(inventoriedCount),
              if (failedCount > 0) context.multiLanguage.failedToProcess(failedCount),
            ];
            
            NotificationDialog.show(
              context,
              title: context.multiLanguage.successUPCASE,
              message: messages.join(''),
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            );
            break;

          case InventoryCheckError(:final message):
            LoadingDialog.hide(context);

            ErrorDialog.show(
              context,
              title: context.multiLanguage.errorUPCASE,
              message: TranslateKey.getStringKey(context.multiLanguage, message)
            );
            break;
        }
      },
      builder: (context, state) {
        return CustomScaffold(
          title: context.multiLanguage.inventoryPageTitle,
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
              onPressed: () {
                  ConfirmationDialog.show(
                  context,
                  title: context.multiLanguage.clearDataUPCASE,
                  message: context.multiLanguage.clearDataMessageInventoryCheck,
                  confirmColor: Colors.redAccent,
                  onConfirm: _clearInventory,
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

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.multiLanguage.scannedItemsInventoryCheckLabel(_getScannedItemsCount(state)),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _clearInventory,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: InventoryItemList(items: _getScannedItems(state)),
                ),

                Container(
                  width: 150,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ElevatedButton(
                    onPressed: _getScannedItemsCount(state) > 0 ? _saveInventory : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      context.multiLanguage.saveButton,
                      style: TextStyle(
                        fontSize: 16,
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

  int _getScannedItemsCount(InventoryCheckState state) {
    switch (state) {
      case InventoryCheckScanning(:final scannedItems):
      case InventoryCheckProcessing(:final scannedItems):
      case InventoryItemChecked(:final scannedItems):
      case InventoryListUpdated(:final scannedItems):
      case InventorySaving(:final scannedItems):
        return scannedItems.length;
      default:
        return 0;
    }
  }

  List<InventoryItemEntity> _getScannedItems(InventoryCheckState state) {
    switch (state) {
      case InventoryCheckScanning(:final scannedItems):
      case InventoryCheckProcessing(:final scannedItems):
      case InventoryItemChecked(:final scannedItems):
      case InventoryListUpdated(:final scannedItems):
      case InventorySaving(:final scannedItems):
        return scannedItems;
      default:
        return [];
    }
  }
}