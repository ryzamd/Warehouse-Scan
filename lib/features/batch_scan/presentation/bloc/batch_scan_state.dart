import 'package:equatable/equatable.dart';
import '../../domain/entities/batch_item_entity.dart';
import '../../domain/entities/batch_process_response_entity.dart';

abstract class BatchScanState extends Equatable {
  const BatchScanState();

  @override
  List<Object?> get props => [];
}

class BatchScanInitial extends BatchScanState {}

class BatchScanScanning extends BatchScanState {
  final bool isCameraActive;
  final bool isTorchEnabled;
  final dynamic controller;
  final List<BatchItemEntity> batchItems;

  const BatchScanScanning({
    required this.isCameraActive,
    required this.isTorchEnabled,
    this.controller,
    this.batchItems = const [],
  });

  @override
  List<Object?> get props => [isCameraActive, isTorchEnabled, controller, batchItems];

  BatchScanScanning copyWith({
    bool? isCameraActive,
    bool? isTorchEnabled,
    dynamic controller,
    List<BatchItemEntity>? batchItems,
  }) {
    return BatchScanScanning(
      isCameraActive: isCameraActive ?? this.isCameraActive,
      isTorchEnabled: isTorchEnabled ?? this.isTorchEnabled,
      controller: controller ?? this.controller,
      batchItems: batchItems ?? this.batchItems,
    );
  }
}

class BatchScanProcessing extends BatchScanState {
  final String barcode;
  final List<BatchItemEntity> batchItems;

  const BatchScanProcessing({
    required this.barcode,
    this.batchItems = const [],
  });

  @override
  List<Object> get props => [barcode, batchItems];
}

class BatchItemChecked extends BatchScanState {
  final BatchItemEntity item;
  final List<BatchItemEntity> batchItems;

  const BatchItemChecked({
    required this.item,
    required this.batchItems,
  });

  @override
  List<Object> get props => [item, batchItems];
}

class BatchListUpdated extends BatchScanState {
  final List<BatchItemEntity> batchItems;

  const BatchListUpdated({required this.batchItems});

  @override
  List<Object> get props => [batchItems];
}

class BatchProcessing extends BatchScanState {
  final List<BatchItemEntity> batchItems;
  final String address;
  final double quantity;
  final int operationMode;

  const BatchProcessing({
    required this.batchItems,
    required this.address,
    required this.quantity,
    required this.operationMode,
  });

  @override
  List<Object> get props => [batchItems, address, quantity, operationMode];
}

class BatchProcessSuccess extends BatchScanState {
  final BatchProcessResponseEntity response;
  final List<BatchItemEntity> remainingItems;

  const BatchProcessSuccess({
    required this.response,
    required this.remainingItems,
  });

  @override
  List<Object> get props => [response, remainingItems];
}

class BatchScanError extends BatchScanState {
  final String message;
  final BatchScanState previousState;
  final Map<String, dynamic>? args;

  const BatchScanError({
    required this.message,
    required this.previousState,
    this.args
  });

  @override
  List<Object> get props => [message, previousState, args!];
}