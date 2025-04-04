// lib/features/warehouse_scan/presentation/bloc/warehouse_out/warehouse_out_event.dart
import 'package:equatable/equatable.dart';

abstract class WarehouseOutEvent extends Equatable {
  const WarehouseOutEvent();

  @override
  List<Object> get props => [];
}

class InitializeScanner extends WarehouseOutEvent {
  final dynamic controller; // Using dynamic to avoid import conflicts
  
  const InitializeScanner(this.controller);
  
  @override
  List<Object> get props => [controller];
}

class ScanBarcode extends WarehouseOutEvent {
  final String barcode;

  const ScanBarcode(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class GetMaterialInfoEvent extends WarehouseOutEvent {
  final String code;

  const GetMaterialInfoEvent(this.code);

  @override
  List<Object> get props => [code];
}

class ProcessWarehouseOutEvent extends WarehouseOutEvent {
  final String code;
  final String address;
  final double quantity;

  const ProcessWarehouseOutEvent({
    required this.code,
    required this.address,
    required this.quantity,
  });

  @override
  List<Object> get props => [code, address, quantity];
}

class HardwareScanEvent extends WarehouseOutEvent {
  final String scannedData;

  const HardwareScanEvent(this.scannedData);

  @override
  List<Object> get props => [scannedData];
}

class ClearScannedData extends WarehouseOutEvent {}

class ValidateQuantityEvent extends WarehouseOutEvent {
  final String quantity;
  final double maxQuantity;

  const ValidateQuantityEvent({
    required this.quantity,
    required this.maxQuantity,
  });

  @override
  List<Object> get props => [quantity, maxQuantity];
}