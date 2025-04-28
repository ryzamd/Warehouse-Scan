import 'package:equatable/equatable.dart';
import '../../domain/entities/batch_item_entity.dart';

abstract class BatchScanEvent extends Equatable {
  const BatchScanEvent();

  @override
  List<Object> get props => [];
}

class InitializeScanner extends BatchScanEvent {
  final dynamic controller;
  
  const InitializeScanner(this.controller);
  
  @override
  List<Object> get props => [controller];
}

class ScanBatchItem extends BatchScanEvent {
  final String barcode;

  const ScanBatchItem(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class HardwareScanEvent extends BatchScanEvent {
  final String scannedData;

  const HardwareScanEvent(this.scannedData);

  @override
  List<Object> get props => [scannedData];
}

class CheckBatchItemEvent extends BatchScanEvent {
  final String code;

  const CheckBatchItemEvent(this.code);

  @override
  List<Object> get props => [code];
}

class AddToBatchList extends BatchScanEvent {
  final BatchItemEntity item;

  const AddToBatchList(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromBatchList extends BatchScanEvent {
  final String code;

  const RemoveFromBatchList(this.code);

  @override
  List<Object> get props => [code];
}

class ProcessBatchEvent extends BatchScanEvent {
  final String address;
  final double quantity;
  final int operationMode;

  const ProcessBatchEvent({
    required this.address,
    required this.quantity,
    required this.operationMode,
  });

  @override
  List<Object> get props => [address, quantity, operationMode];
}

class ClearBatchListEvent extends BatchScanEvent {}