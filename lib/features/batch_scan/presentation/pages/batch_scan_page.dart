import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/core/constants/key_code_constants.dart';
import 'package:warehouse_scan/core/localization/context_extension.dart';
import 'package:warehouse_scan/core/widgets/confirmation_dialog.dart';
import 'package:warehouse_scan/core/widgets/error_dialog.dart';
import 'package:warehouse_scan/core/widgets/loading_dialog.dart';
import 'package:warehouse_scan/core/widgets/notification_dialog.dart';
import 'package:warehouse_scan/core/widgets/scafford_custom.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import 'package:warehouse_scan/features/warehouse_scan/data/datasources/scan_service_impl.dart';
import 'package:warehouse_scan/features/warehouse_scan/presentation/widgets/qr_scanner_widget.dart';
import '../../../../core/constants/enum.dart';
import '../../../../core/services/get_translate_key.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../../../core/widgets/batch_scan_dialog.dart';
import '../../domain/entities/batch_item_entity.dart';
import '../bloc/batch_scan_bloc.dart';
import '../bloc/batch_scan_event.dart';
import '../bloc/batch_scan_state.dart';
import '../widgets/batch_item_list.dart';

class BatchScanPage extends StatefulWidget {
  final UserEntity user;

  const BatchScanPage({super.key, required this.user});

  @override
  State<BatchScanPage> createState() => _BatchScanPageState();
}

class _BatchScanPageState extends State<BatchScanPage> with WidgetsBindingObserver {
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
        context.read<BatchScanBloc>().add(HardwareScanEvent(scannedData));
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

      context.read<BatchScanBloc>().add(InitializeScanner(_controller!));

      if (!_cameraActive && _controller != null) {
        _controller!.stop();
      }
    } catch (e) {
      ErrorDialog.show(
        context,
        title: context.multiLanguage.errorUPCASE,
        message: context.multiLanguage.cannotAccessCamera(e.toString()),
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
            context.read<BatchScanBloc>().add(
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

  void _processBatch() {
    String oldAddress = '';
    final items = _getBatchItems(context.read<BatchScanBloc>().state);

    if (items.isEmpty) {
      ErrorDialog.show(
        context,
        title: context.multiLanguage.errorUPCASE,
        message: context.multiLanguage.batchIsEmptyMessage,
      );
      return;
    }

    if (items.isNotEmpty && items[0].oldAddress.isNotEmpty) {
      oldAddress = items[0].oldAddress;
    }

    BatchScanWarehouseDialog.show(
      context,
      oldAddress: oldAddress,
      onProcessBatch: (address, quantity, operationMode) {
        context.read<BatchScanBloc>().add(
          ProcessBatchEvent(
            address: address,
            quantity: quantity,
            operationMode: operationMode,
          ),
        );
      },
    );
  }

  void _clearBatch() {
    ConfirmationDialog.show(
      context,
      title: context.multiLanguage.clearDataTitleUPCASE,
      message: context.multiLanguage.clearDataMessage,
      confirmText: context.multiLanguage.clearButton,
      cancelText: context.multiLanguage.cancelButton,
      confirmColor: Colors.red,
      onConfirm: () {
        context.read<BatchScanBloc>().add(ClearBatchListEvent());
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
        context.read<BatchScanBloc>().add(ScanBatchItem(rawValue));
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BatchScanBloc, BatchScanState>(
      listener: (context, state) {
        switch(state){
          case BatchProcessing():
            LoadingDialog.show(context);
          break;

          case BatchProcessSuccess():
            if (DialogUtils.isDialogShowing(DialogTypes.loading)) {
              Navigator.of(context).pop();
            }
            
            final successCount = state.response.results
              .where((result) => result.isSuccess)
              .length;
            
            final failCount = state.response.results.length - successCount;
            
            NotificationDialog.show(
              context,
              title: context.multiLanguage.successUPCASE,
                message: '${context.multiLanguage.successfullyProcessed(successCount)}'
                    '${failCount > 0 ? '\n${context.multiLanguage.failedToProcess(failCount)}' : ''}',
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
            );
          break;

          case BatchScanError():
            if (DialogUtils.isDialogShowing(DialogTypes.loading)) {
              Navigator.of(context).pop();
            }
            
            ErrorDialog.show(
              context,
              title: context.multiLanguage.errorUPCASE,
              message: TranslateKey.getStringKey(
                context.multiLanguage,
                state.message,
                args: state.args,
              ),
            );
          break;
        }
      },
      builder: (context, state) {
        final items = _getBatchItems(state);
        
        return CustomScaffold(
          title: context.multiLanguage.batchScanTitleUPCASE,
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
                        context.multiLanguage.batchItems(items.length),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _clearBatch,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: BatchItemList(items: items),
                ),

                Container(
                  width: 150,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: ElevatedButton(
                    onPressed: items.isEmpty ? null : _processBatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      context.multiLanguage.executeButton,
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

  List<BatchItemEntity> _getBatchItems(BatchScanState state) {
    switch (state) {
      case BatchScanScanning(:final batchItems):
      case BatchScanProcessing(:final batchItems):
      case BatchItemChecked(:final batchItems):
      case BatchListUpdated(:final batchItems):
      case BatchProcessing(:final batchItems):
        return batchItems;
      case BatchProcessSuccess(:final remainingItems):
        return remainingItems;
      default:
        return [];
    }
  }
}