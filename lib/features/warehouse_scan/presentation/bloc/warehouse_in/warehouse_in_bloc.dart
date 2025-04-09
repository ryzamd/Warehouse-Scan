// lib/features/warehouse_scan/presentation/bloc/warehouse_in/warehouse_in_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
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
    
    // Listen for connection changes
    connectionChecker.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.disconnected) {
        // Handle disconnection
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
    
    // Show processing state
    emit(WarehouseInProcessing(event.barcode));
    
    // Process the barcode
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
    
    // Check for internet connection
    if (!(await connectionChecker.hasConnection)) {
      emit(WarehouseInError(
        message: 'No internet connection. Please check your network.',
        previousState: state,
      ));
      return;
    }
    
    try {
      final result = await processWarehouseIn(
        ProcessWarehouseInParams(
          code: event.code,
          userName: currentUser.name,
        ),
      );
      
      result.fold(
        (failure) {
          debugPrint('Warehouse in processing failed: ${failure.message}');
          emit(WarehouseInError(
            message: 'Data has already been stored.',
            previousState: state,
          ));
        },
        (data) {
          debugPrint('Warehouse in processing successful');
          emit(WarehouseInSuccess(data));
        },
      );
    } catch (e) {
      
      debugPrint('Error processing warehouse in: $e');
      emit(WarehouseInError(
        message: 'Data has already been stored.',
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
    
    // Show processing state
    emit(WarehouseInProcessing(event.scannedData));
    
    // Process the barcode
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