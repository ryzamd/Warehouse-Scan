import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import '../../../../core/services/get_translate_key.dart';
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
        message: StringKey.thisItemHasBeenScannedMessage,
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
    if (!await connectionChecker.hasConnection) {
      emit(InventoryCheckError(
        message: StringKey.networkErrorMessage,
        previousState: state,
      ));
      return;
    }
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
            message: StringKey.materialNotFound,
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
        message: StringKey.errorWhileCheckingMaterialMessage,
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
        message: StringKey.materialIsEmptyMessage,
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
        (response) {
          final inventoriedCount = response.results.where((result) => result.isInventoried).length;
          final failedCount = response.results.where((result) => result.hasError).length;
          
          final Map<String, String> inventoriedItems = {};
          final Map<String, String> failedItems = {};
          
          for (final result in response.results) {
            if (result.isInventoried) {
              inventoriedItems[result.code] = result.message;
            } else if (result.hasError) {
              failedItems[result.code] = result.message;
            }
          }
          
          final updatedItems = _scannedItems.map((item) {
            if (inventoriedItems.containsKey(item.code)) {
              return item.copyWith(
                isInventoried: true,
                statusMessage: inventoriedItems[item.code] ?? '',
              );
            } else if (failedItems.containsKey(item.code)) {
              return item.copyWith(
                isError: true,
                statusMessage: failedItems[item.code] ?? '',
              );
            }
            return item;
          }).toList();
          
          _scannedItems = updatedItems.where((item) => !response.results.any((r) => r.isSuccess && r.code == item.code)).toList();
          
          emit(InventorySaveSuccess(
            savedItems: response.results.where((r) => r.isSuccess).map((r) => r.code).toList(),
            inventoriedItems: response.results.where((r) => r.isInventoried).map((r) => r.code).toList(),
            failedItems: response.results.where((r) => r.hasError).map((r) => r.code).toList(),
            inventoriedCount: inventoriedCount,
            failedCount: failedCount,
          ));
          
          if (_scannedItems.isNotEmpty) {
            emit(InventoryListUpdated(scannedItems: _scannedItems));
          } else {
            emit(InventoryCheckScanning(
              isCameraActive: true,
              isTorchEnabled: false,
              controller: scannerController,
              scannedItems: _scannedItems,
            ));
          }
        },
      );
    } catch (e) {
      emit(InventoryCheckError(
        message: StringKey.cannotSavingInventoryListMessage,
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