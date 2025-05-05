import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/core/constants/key_code_constants.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import '../../../../../core/services/get_translate_key.dart';
import '../../../domain/usecases/process_warehouse_in.dart';
import 'warehouse_in_event.dart';
import 'warehouse_in_state.dart';

class WarehouseInBloc extends Bloc<WarehouseInEvent, WarehouseInState> {
  final ProcessWarehouseIn processWarehouseIn;
  final InternetConnectionChecker connectionChecker;
  final UserEntity currentUser;
  bool _isProcessing = false;
  
  MobileScannerController? scannerController;

  WarehouseInBloc({
    required this.processWarehouseIn,
    required this.connectionChecker,
    required this.currentUser,
  }) : super(WarehouseInInitial()) {
    on<InitializeScanner>(_onInitializeScanner);
    on<ScanBarcode>(_onScanBarcode);
    on<ProcessWarehouseInEvent>(_onProcessWarehouseIn);
    on<HardwareScanEvent>(_onHardwareScan);
    on<ClearScannedData>(_onClearScannedData);
    
    connectionChecker.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.disconnected) {
        debugPrint('Internet connection lost!');
      }
    });
  }
  
  void _onInitializeScanner(
    InitializeScanner event,
    Emitter<WarehouseInState> emit,
  ) {
    debugPrint('Initializing scanner controller');
    
    scannerController = event.controller as MobileScannerController;
    
    emit(WarehouseInScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
    ));
  }
  
  Future<void> _onScanBarcode(
    ScanBarcode event,
    Emitter<WarehouseInState> emit,
  ) async {
    debugPrint('Barcode scanned: ${event.barcode}');
    
    emit(WarehouseInProcessing(event.barcode));
    
    add(ProcessWarehouseInEvent(event.barcode));
  }
  
  Future<void> _onProcessWarehouseIn(
    ProcessWarehouseInEvent event,
    Emitter<WarehouseInState> emit,
  ) async {

    if(_isProcessing){
      return;
    }

    _isProcessing = true;
    debugPrint('Processing warehouse in for code: ${event.code}');
    
    try {
      final result = await processWarehouseIn(
        ProcessWarehouseInParams(
          code: event.code,
          userName: currentUser.name,
        ),
      );
      
      result.fold(
        (failure) {
          if (failure.message.contains(KeyMessageResponse.NO_DATA)) {
            emit(WarehouseInError(
              message: StringKey.materialNotFound,
              previousState: state,
            ));
          } else if (failure.message.contains(KeyMessageResponse.DATA_HAS_BEEN_STORED)) {
            emit(WarehouseInError(
              message: StringKey.storageFailedMessage,
              previousState: state,
            ));
          } else {
            emit(WarehouseInError(
              message: failure.message,
              previousState: state,
            ));
          }
        },
        (data) {
          debugPrint('Warehouse in processing successful');
          emit(WarehouseInSuccess(data));
        },
      );
    } catch (e) {
      emit(WarehouseInError(
        message: e.toString(),
        previousState: state,
      ));

    } finally {
      _isProcessing = false;
    }
  }
  
  void _onHardwareScan(
    HardwareScanEvent event,
    Emitter<WarehouseInState> emit,
  ) {
    debugPrint('Hardware scan detected: ${event.scannedData}');
    
    emit(WarehouseInProcessing(event.scannedData));
    
    add(ProcessWarehouseInEvent(event.scannedData));
  }
  
  void _onClearScannedData(
    ClearScannedData event,
    Emitter<WarehouseInState> emit,
  ) {
    if (state is WarehouseInScanning) {
      emit((state as WarehouseInScanning).copyWith());
    } else {
      emit(WarehouseInScanning(
        isCameraActive: true,
        isTorchEnabled: false,
        controller: scannerController,
      ));
    }
  }
  
  @override
  Future<void> close() {
    scannerController?.dispose();
    return super.close();
  }
}