// lib/features/warehouse_scan/presentation/bloc/warehouse_out/warehouse_out_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
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
    
    // Show processing state
    emit(WarehouseOutProcessing(event.barcode));
    
    // Get material info
    add(GetMaterialInfoEvent(event.barcode));
  }
  
  Future<void> _onGetMaterialInfo(
    GetMaterialInfoEvent event,
    Emitter<WarehouseOutState> emit,
  ) async {
    debugPrint('Getting material info for code: ${event.code}');
    
    // Check for internet connection
    if (!(await connectionChecker.hasConnection)) {
      emit(WarehouseOutError(
        message: 'No internet connection. Please check your network.',
        previousState: state,
      ));
      return;
    }
    
    try {
      final result = await getMaterialInfo(
        GetMaterialInfoParams(
          code: event.code,
          userName: currentUser.name, // Sử dụng userName từ currentUser
        ),
      );
      
      result.fold(
        (failure) {
          debugPrint('Failed to get material info: ${failure.message}');
          emit(WarehouseOutError(
            message: failure.message,
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
        message: 'Failed to get material information',
        previousState: state,
      ));
    }
  }
  
  Future<void> _onProcessWarehouseOut(
    ProcessWarehouseOutEvent event,
    Emitter<WarehouseOutState> emit,
  ) async {
    debugPrint('Processing warehouse out: ${event.code}, ${event.address}, ${event.quantity}');
    
    // Check for internet connection
    if (!(await connectionChecker.hasConnection)) {
      emit(WarehouseOutError(
        message: 'No internet connection. Please check your network.',
        previousState: state,
      ));
      return;
    }
    
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
          userName: currentUser.name, // Sử dụng userName từ currentUser
          address: event.address,
          quantity: event.quantity,
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
        message: 'Failed to process warehouse out',
        previousState: state is MaterialInfoLoaded ? state : WarehouseOutInitial(),
      ));
    }
  }
  
  void _onHardwareScan(
    HardwareScanEvent event,
    Emitter<WarehouseOutState> emit,
  ) {
    debugPrint('Hardware scan detected: ${event.scannedData}');
    
    // Show processing state
    emit(WarehouseOutProcessing(event.scannedData));
    
    // Get material info
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
      
      if (quantity == null) {
        emit(currentState.copyWith(
          quantityError: 'Please enter a valid number',
          quantityExceeded: false,
        ));
        return;
      }
      
      if (quantity < 0) {
        emit(currentState.copyWith(
          quantityError: 'Quantity cannot be negative',
          quantityExceeded: false,
        ));
        return;
      }
      
      if (quantity > event.maxQuantity) {
        emit(currentState.copyWith(
          quantityError: 'Quantity exceeds available amount',
          quantityExceeded: true,
        ));
        return;
      }
      
      emit(currentState.copyWith(
        quantityError: null,
        quantityExceeded: false,
      ));
    }
  }
  
  @override
  Future<void> close() {
    scannerController?.dispose();
    return super.close();
  }
}