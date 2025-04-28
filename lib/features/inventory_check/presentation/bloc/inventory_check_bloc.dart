import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import '../../domain/entities/inventory_item_entity.dart';
import '../../domain/usecases/check_item_code.dart';
import '../../domain/usecases/save_inventory_items.dart';
import 'inventory_check_event.dart';
import 'inventory_check_state.dart';

class InventoryCheckBloc extends Bloc<InventoryCheckEvent, InventoryCheckState> {
  final CheckItemCode checkItemCode;
  final SaveInventoryItems saveInventoryItems;
  final InternetConnectionChecker connectionChecker;
  final UserEntity currentUser;
  
  List<InventoryItemEntity> _scannedItems = [];
  MobileScannerController? scannerController;

  InventoryCheckBloc({
    required this.checkItemCode,
    required this.saveInventoryItems,
    required this.connectionChecker,
    required this.currentUser,
  }) : super(InventoryCheckInitial()) {
    on<InitializeScanner>(_onInitializeScanner);
    on<ScanInventoryItem>(_onScanInventoryItem);
    on<CheckInventoryItem>(_onCheckInventoryItem);
    on<AddToInventoryList>(_onAddToInventoryList);
    on<RemoveFromInventoryList>(_onRemoveFromInventoryList);
    on<SaveInventoryListEvent>(_onSaveInventoryList);
    on<ClearInventoryListEvent>(_onClearInventoryList);
    on<HardwareScanEvent>(_onHardwareScan);
  }
  
  void _onInitializeScanner(
    InitializeScanner event,
    Emitter<InventoryCheckState> emit,
  ) {
    scannerController = event.controller as MobileScannerController;
    
    emit(InventoryCheckScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
      scannedItems: _scannedItems,
    ));
  }
  
  Future<void> _onScanInventoryItem(ScanInventoryItem event, Emitter<InventoryCheckState> emit) async {

    final codeExists = _scannedItems.any((item) => item.code == event.barcode);

    if (codeExists) {
      emit(InventoryCheckError(
        message: 'This item has been scanned.',
        previousState: state,
      ));
      
      if (state is InventoryCheckScanning) {
        emit((state as InventoryCheckScanning).copyWith(scannedItems: _scannedItems));
      } else {
        emit(InventoryListUpdated(scannedItems: _scannedItems));
      }
      return;
    }
    
    emit(InventoryCheckProcessing(
      barcode: event.barcode,
      scannedItems: _scannedItems,
    ));
    
    add(CheckInventoryItem(event.barcode));
  }
  
  Future<void> _onCheckInventoryItem(CheckInventoryItem event, Emitter<InventoryCheckState> emit) async {
    try {

      final result = await checkItemCode(
        CheckItemCodeParams(
          code: event.code,
          userName: currentUser.name,
        ),
      );
      
      result.fold(
        (failure) {
          emit(InventoryCheckError(
            message: failure.message,
            previousState: state,
          ));
          
          if (state is InventoryCheckScanning) {
            emit((state as InventoryCheckScanning).copyWith(scannedItems: _scannedItems));
          } else {
            emit(InventoryListUpdated(scannedItems: _scannedItems));
          }
        },
        (item) {
          add(AddToInventoryList(item));
        },
      );
    } catch (e) {
      emit(InventoryCheckError(
        message: 'Error while checking materials',
        previousState: state,
      ));
      
      if (state is InventoryCheckScanning) {
        emit((state as InventoryCheckScanning).copyWith(scannedItems: _scannedItems));
      } else {
        emit(InventoryListUpdated(scannedItems: _scannedItems));
      }
    }
  }
  
  void _onAddToInventoryList(AddToInventoryList event, Emitter<InventoryCheckState> emit) {
    if (!_scannedItems.any((item) => item.code == event.item.code)) {
      _scannedItems = [..._scannedItems, event.item];
      
      emit(InventoryItemChecked(
        item: event.item,
        scannedItems: _scannedItems,
      ));
      
      emit(InventoryListUpdated(scannedItems: _scannedItems));
    } else {
      emit(InventoryListUpdated(scannedItems: _scannedItems));
    }
  }
  
  void _onRemoveFromInventoryList(RemoveFromInventoryList event, Emitter<InventoryCheckState> emit) {
    _scannedItems = _scannedItems.where((item) => item.code != event.code).toList();
    
    emit(InventoryListUpdated(scannedItems: _scannedItems));
  }
  
  Future<void> _onSaveInventoryList(SaveInventoryListEvent event, Emitter<InventoryCheckState> emit) async {
    if (_scannedItems.isEmpty) {
      emit(InventoryCheckError(
        message: 'Material is empty',
        previousState: state,
      ));
      return;
    }
    
    emit(InventorySaving(scannedItems: _scannedItems));
    
    try {
      final result = await saveInventoryItems(
        SaveInventoryItemsParams(codes: _scannedItems.map((item) => item.code).toList()),
      );
      
      result.fold(
        (failure) {
          emit(InventoryCheckError(
            message: failure.message,
            previousState: state,
          ));
          
          emit(InventoryListUpdated(scannedItems: _scannedItems));
        },
        (savedItems) {
          emit(InventorySaveSuccess(savedItems: savedItems));
          
          _scannedItems = [];
          
          emit(InventoryCheckScanning(
            isCameraActive: true,
            isTorchEnabled: false,
            controller: scannerController,
            scannedItems: _scannedItems,
          ));
        },
      );
    } catch (e) {
      emit(InventoryCheckError(
        message: 'Cannot saving inventory list.',
        previousState: state,
      ));
      
      emit(InventoryListUpdated(scannedItems: _scannedItems));
    }
  }
  
  void _onClearInventoryList(ClearInventoryListEvent event, Emitter<InventoryCheckState> emit) {
    _scannedItems = [];
    
    emit(InventoryListUpdated(scannedItems: _scannedItems));
    
    emit(InventoryCheckScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
      scannedItems: _scannedItems,
    ));
  }
  
  void _onHardwareScan(HardwareScanEvent event, Emitter<InventoryCheckState> emit) {
    add(ScanInventoryItem(event.scannedData));
  }
  
  @override
  Future<void> close() {
    scannerController?.dispose();
    return super.close();
  }
}