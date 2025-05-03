import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import '../../../../../core/services/get_translate_key.dart';
import '../../../domain/usecases/get_material_info.dart';
import '../../../domain/usecases/process_warehouse_out.dart';
import 'warehouse_out_event.dart';
import 'warehouse_out_state.dart';

class WarehouseOutBloc extends Bloc<WarehouseOutEvent, WarehouseOutState> {
  final GetMaterialInfo getMaterialInfo;
  final ProcessWarehouseOut processWarehouseOut;
  final InternetConnectionChecker connectionChecker;
  final UserEntity currentUser;
  
  MobileScannerController? scannerController;

  WarehouseOutBloc({
    required this.getMaterialInfo,
    required this.processWarehouseOut,
    required this.connectionChecker,
    required this.currentUser,
  }) : super(WarehouseOutInitial()) {
    on<InitializeScanner>(_onInitializeScanner);
    on<ScanBarcode>(_onScanBarcode);
    on<GetMaterialInfoEvent>(_onGetMaterialInfo);
    on<ProcessWarehouseOutEvent>(_onProcessWarehouseOut);
    on<HardwareScanEvent>(_onHardwareScan);
    on<ClearScannedData>(_onClearScannedData);
    on<ValidateQuantityEvent>(_onValidateQuantity);
    
    connectionChecker.onStatusChange.listen((status) {
      if (status == InternetConnectionStatus.disconnected) {
        debugPrint('Internet connection lost!');
      }
    });
  }
  
  void _onInitializeScanner(
    InitializeScanner event,
    Emitter<WarehouseOutState> emit,
  ) {
    debugPrint('Initializing scanner controller');
    
    scannerController = event.controller as MobileScannerController;
    
    emit(WarehouseOutScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
    ));
  }
  
  Future<void> _onScanBarcode(
    ScanBarcode event,
    Emitter<WarehouseOutState> emit,
  ) async {
    debugPrint('Barcode scanned: ${event.barcode}');
    
    emit(WarehouseOutProcessing(event.barcode));
    
    add(GetMaterialInfoEvent(event.barcode));
  }
  
  Future<void> _onGetMaterialInfo(
    GetMaterialInfoEvent event,
    Emitter<WarehouseOutState> emit,
  ) async {
    debugPrint('Getting material info for code: ${event.code}');
    
    if (!(await connectionChecker.hasConnection)) {
      emit(WarehouseOutError(
        message: StringKey.networkErrorMessage,
        previousState: state,
      ));
      return;
    }
    
    try {
      final result = await getMaterialInfo(
        GetMaterialInfoParams(
          code: event.code,
          userName: currentUser.name,
        ),
      );
      
      result.fold(
        (failure) {
          debugPrint('Failed to get material info: ${failure.message}');
          emit(WarehouseOutError(
            message: StringKey.materialWithCodeNotFoundMessage,
            args: {"code": event.code.toString()},
            previousState: state,
          ));
        },
        (material) {
          debugPrint('Material info loaded successfully');
          emit(MaterialInfoLoaded(material: material));
        },
      );
    } catch (e) {
      debugPrint('Error getting material info: $e');
      emit(WarehouseOutError(
        message: StringKey.failedToGetMaterialInformation,
        previousState: state,
      ));
    }
  }
  
  Future<void> _onProcessWarehouseOut(
    ProcessWarehouseOutEvent event,
    Emitter<WarehouseOutState> emit,
  ) async {
    debugPrint('Processing warehouse out: ${event.code}, ${event.address}, ${event.quantity}');
    
    // Show processing state
    emit(WarehouseOutProcessingRequest(
      code: event.code,
      address: event.address,
      quantity: event.quantity,
    ));
    
    try {
      final result = await processWarehouseOut(
        ProcessWarehouseOutParams(
          code: event.code,
          userName: currentUser.name,
          address: event.address,
          quantity: event.quantity,
          optionFunction: event.optionFunction,
        ),
      );
      
      result.fold(
        (failure) {
          debugPrint('Warehouse out processing failed: ${failure.message}');
          emit(WarehouseOutError(
            message: failure.message,
            previousState: state is MaterialInfoLoaded ? state : WarehouseOutInitial(),
          ));
        },
        (success) {
          debugPrint('Warehouse out processing successful');
          emit(WarehouseOutSuccess());
        },
      );
    } catch (e) {
      debugPrint('Error processing warehouse out: $e');
      emit(WarehouseOutError(
        message: StringKey.failedToProcessExportingWarehouse,
        previousState: state is MaterialInfoLoaded ? state : WarehouseOutInitial(),
      ));
    }
  }
  
  void _onHardwareScan(
    HardwareScanEvent event,
    Emitter<WarehouseOutState> emit,
  ) {
    debugPrint('Hardware scan detected: ${event.scannedData}');
    
    emit(WarehouseOutProcessing(event.scannedData));
    
    add(GetMaterialInfoEvent(event.scannedData));
  }
  
  void _onClearScannedData(
    ClearScannedData event,
    Emitter<WarehouseOutState> emit,
  ) {
    if (state is WarehouseOutScanning) {
      emit((state as WarehouseOutScanning).copyWith());
    } else {
      emit(WarehouseOutScanning(
        isCameraActive: true,
        isTorchEnabled: false,
        controller: scannerController,
      ));
    }
  }
  
  void _onValidateQuantity(
    ValidateQuantityEvent event,
    Emitter<WarehouseOutState> emit,
  ) {
    if (state is MaterialInfoLoaded) {
      final currentState = state as MaterialInfoLoaded;
      final double? quantity = double.tryParse(event.quantity);
      String? error;
      bool exceeded = false;
      
      if (event.quantity.isEmpty) {
        // Don't show error for empty field
        error = null;
      } else if (quantity == null) {
        error = 'Please enter a valid number';
      } else if (quantity <= 0) {
        error = 'Quantity must be greater than 0';
      } else if (quantity > event.maxQuantity) {
        error = 'Quantity exceeds available amount';
        exceeded = true;
      }
      
      // Only update validation properties, not create a new state type
      emit(currentState.copyWith(
        quantityError: error,
        quantityExceeded: exceeded,
      ));
    }
  }
  
  @override
  Future<void> close() {
    scannerController?.dispose();
    return super.close();
  }
}