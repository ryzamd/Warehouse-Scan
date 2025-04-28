import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:warehouse_scan/features/auth/login/domain/entities/user_entity.dart';
import '../../data/models/batch_process_response_model.dart';
import '../../domain/entities/batch_item_entity.dart';
import '../../domain/usecases/check_batch_code.dart';
import '../../domain/usecases/process_batch.dart';
import 'batch_scan_event.dart';
import 'batch_scan_state.dart';

class BatchScanBloc extends Bloc<BatchScanEvent, BatchScanState> {
  final CheckBatchCode checkBatchCode;
  final ProcessBatch processBatch;
  final InternetConnectionChecker connectionChecker;
  final UserEntity currentUser;
  
  List<BatchItemEntity> _batchItems = [];
  MobileScannerController? scannerController;

  BatchScanBloc({
    required this.checkBatchCode,
    required this.processBatch,
    required this.connectionChecker,
    required this.currentUser,
  }) : super(BatchScanInitial()) {
    on<InitializeScanner>(_onInitializeScanner);
    on<ScanBatchItem>(_onScanBatchItem);
    on<CheckBatchItemEvent>(_onCheckBatchItem);
    on<AddToBatchList>(_onAddToBatchList);
    on<RemoveFromBatchList>(_onRemoveFromBatchList);
    on<ProcessBatchEvent>(_onProcessBatch);
    on<ClearBatchListEvent>(_onClearBatchList);
    on<HardwareScanEvent>(_onHardwareScan);
  }
  
  void _onInitializeScanner(
    InitializeScanner event,
    Emitter<BatchScanState> emit,
  ) {
    scannerController = event.controller as MobileScannerController;
    
    emit(BatchScanScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
      batchItems: _batchItems,
    ));
  }
  
  Future<void> _onScanBatchItem(ScanBatchItem event, Emitter<BatchScanState> emit) async {
    final codeExists = _batchItems.any((item) => item.code == event.barcode);

    if (codeExists) {
      emit(BatchScanError(
        message: 'This item is already in the list.',
        previousState: state,
      ));
      
      if (state is BatchScanScanning) {
        emit((state as BatchScanScanning).copyWith(batchItems: _batchItems));
      } else {
        emit(BatchListUpdated(batchItems: _batchItems));
      }
      return;
    }
    
    emit(BatchScanProcessing(
      barcode: event.barcode,
      batchItems: _batchItems,
    ));
    
    add(CheckBatchItemEvent(event.barcode));
  }
  
  Future<void> _onCheckBatchItem(CheckBatchItemEvent event, Emitter<BatchScanState> emit) async {
    try {
      final result = await checkBatchCode(
        CheckBatchCodeParams(
          code: event.code,
          userName: currentUser.name,
        ),
      );
      
      result.fold(
        (failure) {
          emit(BatchScanError(
            message: failure.message,
            previousState: state,
          ));
          
          if (state is BatchScanScanning) {
            emit((state as BatchScanScanning).copyWith(batchItems: _batchItems));
          } else {
            emit(BatchListUpdated(batchItems: _batchItems));
          }
        },
        (item) {
          add(AddToBatchList(item));
        },
      );
    } catch (e) {
      emit(BatchScanError(
        message: 'Error checking item: ${e.toString()}',
        previousState: state,
      ));
      
      if (state is BatchScanScanning) {
        emit((state as BatchScanScanning).copyWith(batchItems: _batchItems));
      } else {
        emit(BatchListUpdated(batchItems: _batchItems));
      }
    }
  }
  
  void _onAddToBatchList(AddToBatchList event, Emitter<BatchScanState> emit) {
    if (!_batchItems.any((item) => item.code == event.item.code)) {
      _batchItems = [..._batchItems, event.item];
      
      emit(BatchItemChecked(
        item: event.item,
        batchItems: _batchItems,
      ));
      
      emit(BatchListUpdated(batchItems: _batchItems));
    } else {
      emit(BatchListUpdated(batchItems: _batchItems));
    }
  }
  
  void _onRemoveFromBatchList(RemoveFromBatchList event, Emitter<BatchScanState> emit) {
    _batchItems = _batchItems.where((item) => item.code != event.code).toList();
    
    emit(BatchListUpdated(batchItems: _batchItems));
  }
  
  Future<void> _onProcessBatch(ProcessBatchEvent event, Emitter<BatchScanState> emit) async {
    if (_batchItems.isEmpty) {
      emit(BatchScanError(
        message: 'Batch is empty. Please scan items first.',
        previousState: state,
      ));
      return;
    }
    
    emit(BatchProcessing(
      batchItems: _batchItems,
      address: event.address,
      quantity: event.quantity,
      operationMode: event.operationMode,
    ));
    
    try {
      final result = await processBatch(
        ProcessBatchParams(
          codes: _batchItems.map((item) => item.code).toList(),
          userName: currentUser.name,
          address: event.address,
          quantity: event.quantity,
          operationMode: event.operationMode,
        ),
      );
      
      result.fold(
        (failure) {
          emit(BatchScanError(
            message: failure.message,
            previousState: state,
          ));
          
          emit(BatchListUpdated(batchItems: _batchItems));
        },
        (response) {
          final successCodes = response.results
              .where((result) => result.isSuccess)
              .map((result) => result.code)
              .toSet();
          
          final updatedItems = _batchItems.map((item) {
            final result = response.results.firstWhere(
              (r) => r.code == item.code,
              orElse: () => const BatchResultModel(
                code: '',
                status: '',
              ),
            );
            
            if (result.code.isEmpty) {
              return item;
            }
            
            return item.copyWith(
              isProcessed: result.isSuccess,
              isError: !result.isSuccess,
              errorMessage: result.errorMessage ?? '',
            );
          }).toList();
          
          _batchItems = updatedItems.where((item) => !item.isProcessed).toList();
          
          emit(BatchProcessSuccess(
            response: response,
            remainingItems: _batchItems,
          ));
          
          if (_batchItems.isNotEmpty) {
            emit(BatchListUpdated(batchItems: _batchItems));
          } else {
            emit(BatchScanScanning(
              isCameraActive: true,
              isTorchEnabled: false,
              controller: scannerController,
              batchItems: _batchItems,
            ));
          }
        },
      );
    } catch (e) {
      emit(BatchScanError(
        message: 'Error processing batch: ${e.toString()}',
        previousState: state,
      ));
      
      emit(BatchListUpdated(batchItems: _batchItems));
    }
  }
  
  void _onClearBatchList(ClearBatchListEvent event, Emitter<BatchScanState> emit) {
    _batchItems = [];
    
    emit(BatchListUpdated(batchItems: _batchItems));
    
    emit(BatchScanScanning(
      isCameraActive: true,
      isTorchEnabled: false,
      controller: scannerController,
      batchItems: _batchItems,
    ));
  }
  
  void _onHardwareScan(HardwareScanEvent event, Emitter<BatchScanState> emit) {
    add(ScanBatchItem(event.scannedData));
  }
  
  @override
  Future<void> close() {
    scannerController?.dispose();
    return super.close();
  }
}