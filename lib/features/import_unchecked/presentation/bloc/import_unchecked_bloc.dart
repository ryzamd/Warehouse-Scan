import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import '../../../../core/services/get_translate_key.dart';
import '../../data/models/import_unchecked_response_model.dart';
import '../../domain/entities/import_unchecked_item_entity.dart';
import '../../domain/usecases/check_import_unchecked_code.dart';
import '../../domain/usecases/import_unchecked_data.dart';
import 'import_unchecked_event.dart';
import 'import_unchecked_state.dart';

class ImportUncheckedBloc extends Bloc<ImportUncheckedEvent, ImportUncheckedState> {
  final CheckImportUncheckedCode checkImportUncheckedCode;
  final ImportUncheckedData importUncheckedData;
  final InternetConnectionChecker connectionChecker;
  final UserEntity currentUser;
  
  List<ImportUncheckedItemEntity> _scannedItems = [];
  MobileScannerController? scannerController;

  ImportUncheckedBloc({
    required this.checkImportUncheckedCode,
    required this.importUncheckedData,
    required this.connectionChecker,
    required this.currentUser,
  }) : super(ImportUncheckedInitial()) {
    on<InitializeScanner>(_onInitializeScanner);
    on<ScanImportUncheckedItem>(_onScanImportUncheckedItem);
    on<CheckImportUncheckedItemEvent>(_onCheckImportUncheckedItem);
    on<AddToImportUncheckedList>(_onAddToImportUncheckedList);
    on<RemoveFromImportUncheckedList>(_onRemoveFromImportUncheckedList);
    on<ImportUncheckedDataEvent>(_onImportUncheckedData);
    on<ClearImportUncheckedListEvent>(_onClearImportUncheckedList);
    on<HardwareScanEvent>(_onHardwareScan);
  }
  
  void _onInitializeScanner(
    InitializeScanner event,
    Emitter<ImportUncheckedState> emit,
  ) {
    scannerController = event.controller as MobileScannerController;
    
    emit(ImportUncheckedScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
      scannedItems: _scannedItems,
    ));
  }
  
  Future<void> _onScanImportUncheckedItem(ScanImportUncheckedItem event, Emitter<ImportUncheckedState> emit) async {
    final codeExists = _scannedItems.any((item) => item.code == event.barcode);

    if (codeExists) {
      emit(ImportUncheckedError(
        message: StringKey.thisItemHasBeenScannedMessage,
        previousState: state,
      ));
      
      if (state is ImportUncheckedScanning) {
        emit((state as ImportUncheckedScanning).copyWith(scannedItems: _scannedItems));
      } else {
        emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
      }
      return;
    }
    
    emit(ImportUncheckedProcessing(
      barcode: event.barcode,
      scannedItems: _scannedItems,
    ));
    
    add(CheckImportUncheckedItemEvent(event.barcode));
  }
  
  Future<void> _onCheckImportUncheckedItem(CheckImportUncheckedItemEvent event, Emitter<ImportUncheckedState> emit) async {
    try {
      final result = await checkImportUncheckedCode(
        CheckImportUncheckedCodeParams(
          code: event.code,
          userName: currentUser.name,
        ),
      );
      
      result.fold(
        (failure) {
          emit(ImportUncheckedError(
            message: StringKey.materialNotFound,
            previousState: state,
          ));
          
          if (state is ImportUncheckedScanning) {
            emit((state as ImportUncheckedScanning).copyWith(scannedItems: _scannedItems));
          } else {
            emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
          }
        },
        (item) {
          add(AddToImportUncheckedList(item));
        },
      );
    } catch (e) {
      emit(ImportUncheckedError(
        message: StringKey.errorWhileCheckingMaterialMessage,
        previousState: state,
      ));
      
      if (state is ImportUncheckedScanning) {
        emit((state as ImportUncheckedScanning).copyWith(scannedItems: _scannedItems));
      } else {
        emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
      }
    }
  }
  
  void _onAddToImportUncheckedList(AddToImportUncheckedList event, Emitter<ImportUncheckedState> emit) {
    if (!_scannedItems.any((item) => item.code == event.item.code)) {
      _scannedItems = [..._scannedItems, event.item];
      
      emit(ImportUncheckedItemChecked(
        item: event.item,
        scannedItems: _scannedItems,
      ));
      
      emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
    } else {
      emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
    }
  }
  
  void _onRemoveFromImportUncheckedList(RemoveFromImportUncheckedList event, Emitter<ImportUncheckedState> emit) {
    _scannedItems = _scannedItems.where((item) => item.code != event.code).toList();
    
    emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
  }
  
  Future<void> _onImportUncheckedData(ImportUncheckedDataEvent event, Emitter<ImportUncheckedState> emit) async {
    if (_scannedItems.isEmpty) {
      emit(ImportUncheckedError(
        message: StringKey.materialIsEmptyMessage,
        previousState: state,
      ));
      return;
    }
    
    emit(ImportUncheckedPulling(scannedItems: _scannedItems));
    
    try {
      final result = await importUncheckedData(
        ImportUncheckedDataParams(
          codes: _scannedItems.map((item) => item.code).toList(),
          userName: currentUser.name,
        ),
      );
      
      result.fold(
        (failure) {
          emit(ImportUncheckedError(
            message: failure.message,
            previousState: state,
          ));
          
          emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
        },
        (response) {
          final successCount = response.results.where((r) => r.isSuccess).length;
          final failedCount = response.results.length - successCount;
          
          final updatedItems = <ImportUncheckedItemEntity>[];
          
          for (final item in _scannedItems) {
            final result = response.results.firstWhere(
              (r) => r.code == item.code,
              orElse: () => const ImportUncheckedResultModel(
                code: '',
                status: 'No response',
                updateMessage: '',
              ),
            );
            
            if (result.isFailed) {
              updatedItems.add(item.copyWith(
                isError: true,
                errorMessage: result.errorMessage ?? result.status,
              ));
            }
          }
          
          _scannedItems = updatedItems;
          
          emit(ImportUncheckedPullSuccess(
            response: response,
            successCount: successCount,
            failedCount: failedCount,
          ));
          
          if (_scannedItems.isNotEmpty) {
            emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
          } else {
            emit(ImportUncheckedScanning(
              isCameraActive: true,
              isTorchEnabled: false,
              controller: scannerController,
              scannedItems: _scannedItems,
            ));
          }
        },
      );
    } catch (e) {
      emit(ImportUncheckedError(
        message: 'Error pulling QC data: ${e.toString()}',
        previousState: state,
      ));
      
      emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
    }
  }
  
  void _onClearImportUncheckedList(ClearImportUncheckedListEvent event, Emitter<ImportUncheckedState> emit) {
    _scannedItems = [];
    
    emit(ImportUncheckedListUpdated(scannedItems: _scannedItems));
    
    emit(ImportUncheckedScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
      scannedItems: _scannedItems,
    ));
  }
  
  void _onHardwareScan(HardwareScanEvent event, Emitter<ImportUncheckedState> emit) {
    add(ScanImportUncheckedItem(event.scannedData));
  }
  
  @override
  Future<void> close() {
    scannerController?.dispose();
    return super.close();
  }
}