// lib/features/warehouse_scan/presentation/bloc/warehouse_in/warehouse_in_event.dart
import 'package:equatable/equatable.dart';

abstract class WarehouseInEvent extends Equatable {
  const WarehouseInEvent();

  @override
  List<Object> get props => [];
}

class InitializeScanner extends WarehouseInEvent {
  final dynamic controller; // Using dynamic to avoid import conflicts
  
  const InitializeScanner(this.controller);
  
  @override
  List<Object> get props => [controller];
}

class ScanBarcode extends WarehouseInEvent {
  final String barcode;

  const ScanBarcode(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class ProcessWarehouseInEvent extends WarehouseInEvent {
  final String code;

  const ProcessWarehouseInEvent(this.code);

  @override
  List<Object> get props => [code];
}

class HardwareScanEvent extends WarehouseInEvent {
  final String scannedData;

  const HardwareScanEvent(this.scannedData);

  @override
  List<Object> get props => [scannedData];
}

class ClearScannedData extends WarehouseInEvent {}