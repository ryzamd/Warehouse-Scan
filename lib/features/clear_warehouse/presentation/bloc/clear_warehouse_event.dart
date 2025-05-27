import 'package:equatable/equatable.dart';
import '../../domain/entities/clear_warehouse_item_entity.dart';

abstract class ClearWarehouseEvent extends Equatable {
  const ClearWarehouseEvent();

  @override
  List<Object> get props => [];
}

class InitializeScanner extends ClearWarehouseEvent {
  final dynamic controller;
  
  const InitializeScanner(this.controller);
  
  @override
  List<Object> get props => [controller];
}

class ScanWarehouseItem extends ClearWarehouseEvent {
  final String barcode;

  const ScanWarehouseItem(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class HardwareScanEvent extends ClearWarehouseEvent {
  final String scannedData;

  const HardwareScanEvent(this.scannedData);

  @override
  List<Object> get props => [scannedData];
}

class CheckWarehouseItemEvent extends ClearWarehouseEvent {
  final String code;

  const CheckWarehouseItemEvent(this.code);

  @override
  List<Object> get props => [code];
}

class AddToWarehouseList extends ClearWarehouseEvent {
  final ClearWarehouseItemEntity item;

  const AddToWarehouseList(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromWarehouseList extends ClearWarehouseEvent {
  final String code;

  const RemoveFromWarehouseList(this.code);

  @override
  List<Object> get props => [code];
}

class ClearWarehouseQuantityEvent extends ClearWarehouseEvent {
  final String code;

  const ClearWarehouseQuantityEvent(this.code);

  @override
  List<Object> get props => [code];
}

class ClearAllWarehouseItemsEvent extends ClearWarehouseEvent {}