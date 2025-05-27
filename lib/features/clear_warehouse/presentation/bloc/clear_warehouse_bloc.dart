import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import '../../../../core/constants/key_code_constants.dart';
import '../../../../core/services/get_translate_key.dart';
import '../../domain/entities/clear_warehouse_item_entity.dart';
import '../../domain/usecases/check_warehouse_item.dart';
import '../../domain/usecases/clear_warehouse_quantity.dart';
import 'clear_warehouse_event.dart';
import 'clear_warehouse_state.dart';

class ClearWarehouseBloc extends Bloc<ClearWarehouseEvent, ClearWarehouseState> {
  final CheckWarehouseItem checkWarehouseItem;
  final ClearWarehouseQuantity clearWarehouseQuantity;
  final InternetConnectionChecker connectionChecker;
  final UserEntity currentUser;
  
  List<ClearWarehouseItemEntity> _scannedItems = [];
  MobileScannerController? scannerController;

  ClearWarehouseBloc({
    required this.checkWarehouseItem,
    required this.clearWarehouseQuantity,
    required this.connectionChecker,
    required this.currentUser,
  }) : super(ClearWarehouseInitial()) {
    on<InitializeScanner>(_onInitializeScanner);
    on<ScanWarehouseItem>(_onScanWarehouseItem);
    on<CheckWarehouseItemEvent>(_onCheckWarehouseItem);
    on<AddToWarehouseList>(_onAddToWarehouseList);
    on<RemoveFromWarehouseList>(_onRemoveFromWarehouseList);
    on<ClearWarehouseQuantityEvent>(_onClearWarehouseQuantity);
    on<ClearAllWarehouseItemsEvent>(_onClearAllWarehouseItems);
    on<HardwareScanEvent>(_onHardwareScan);
  }
  
  void _onInitializeScanner(
    InitializeScanner event,
    Emitter<ClearWarehouseState> emit,
  ) {
    scannerController = event.controller as MobileScannerController;
    
    emit(ClearWarehouseScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
      scannedItems: _scannedItems,
    ));
  }
  
  Future<void> _onScanWarehouseItem(ScanWarehouseItem event, Emitter<ClearWarehouseState> emit) async {
    final codeExists = _scannedItems.any((item) => item.code == event.barcode);

    if (codeExists) {
      emit(ClearWarehouseError(
        message: StringKey.thisItemHasBeenScannedMessage,
        previousState: state,
      ));
      
      if (state is ClearWarehouseScanning) {
        emit((state as ClearWarehouseScanning).copyWith(scannedItems: _scannedItems));
      } else {
        emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
      }
      return;
    }
    
    emit(ClearWarehouseProcessing(
      barcode: event.barcode,
      scannedItems: _scannedItems,
    ));
    
    add(CheckWarehouseItemEvent(event.barcode));
  }
  
  Future<void> _onCheckWarehouseItem(CheckWarehouseItemEvent event, Emitter<ClearWarehouseState> emit) async {
    try {
      final result = await checkWarehouseItem(
        CheckWarehouseItemParams(
          code: event.code,
          userName: currentUser.name,
        ),
      );
      
      result.fold(
        (failure) {
          emit(ClearWarehouseError(
            message: StringKey.materialNotFound,
            previousState: state,
          ));
          
          if (state is ClearWarehouseScanning) {
            emit((state as ClearWarehouseScanning).copyWith(scannedItems: _scannedItems));
          } else {
            emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
          }
        },
        (item) {
          add(AddToWarehouseList(item));
        },
      );
    } catch (e) {
      emit(ClearWarehouseError(
        message: StringKey.errorWhileCheckingMaterialMessage,
        previousState: state,
      ));
      
      if (state is ClearWarehouseScanning) {
        emit((state as ClearWarehouseScanning).copyWith(scannedItems: _scannedItems));
      } else {
        emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
      }
    }
  }
  
  void _onAddToWarehouseList(AddToWarehouseList event, Emitter<ClearWarehouseState> emit) {
    if (!_scannedItems.any((item) => item.code == event.item.code)) {
      _scannedItems = [..._scannedItems, event.item];
      
      emit(ClearWarehouseItemChecked(
        item: event.item,
        scannedItems: _scannedItems,
      ));
      
      emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
    } else {
      emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
    }
  }
  
  void _onRemoveFromWarehouseList(RemoveFromWarehouseList event, Emitter<ClearWarehouseState> emit) {
    _scannedItems = _scannedItems.where((item) => item.code != event.code).toList();
    
    emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
  }
  
  Future<void> _onClearWarehouseQuantity(ClearWarehouseQuantityEvent event, Emitter<ClearWarehouseState> emit) async {
    emit(ClearWarehouseClearing(
      code: event.code,
      scannedItems: _scannedItems,
    ));
    
    try {
      final result = await clearWarehouseQuantity(
        ClearWarehouseQuantityParams(
          code: event.code,
          userName: currentUser.name,
        ),
      );
      
      result.fold(
        (failure) {
          if(failure.message.contains(KeyMessageResponse.NO_DATA)){
            emit(ClearWarehouseError(
              message: StringKey.cannotClearItemMessage,
              previousState: state,
            ));
          }
          
          emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
        },
        (success) {
          _scannedItems = _scannedItems.where((item) => item.code != event.code).toList();
          
          emit(ClearWarehouseClearSuccess(
            code: event.code,
            remainingItems: _scannedItems,
          ));
          
          if (_scannedItems.isNotEmpty) {
            emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
          } else {
            emit(ClearWarehouseScanning(
              isCameraActive: true,
              isTorchEnabled: false,
              controller: scannerController,
              scannedItems: _scannedItems,
            ));
          }
        },
      );
    } catch (_) {
      emit(ClearWarehouseError(
        message: StringKey.errorClearingWarehouseQuantity,
        previousState: state,
      ));
      
      emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
    }
  }
  
  void _onClearAllWarehouseItems(ClearAllWarehouseItemsEvent event, Emitter<ClearWarehouseState> emit) {
    _scannedItems = [];
    
    emit(ClearWarehouseListUpdated(scannedItems: _scannedItems));
    
    emit(ClearWarehouseScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
      scannedItems: _scannedItems,
    ));
  }
  
  void _onHardwareScan(HardwareScanEvent event, Emitter<ClearWarehouseState> emit) {
    add(ScanWarehouseItem(event.scannedData));
  }
  
  @override
  Future<void> close() {
    scannerController?.dispose();
    return super.close();
  }
}