// lib/features/inventory_check/presentation/bloc/inventory_check_event.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item_entity.dart';

abstract class InventoryCheckEvent extends Equatable {
  const InventoryCheckEvent();

  @override
  List<Object> get props => [];
}

class InitializeScanner extends InventoryCheckEvent {
  final dynamic controller;
  
  const InitializeScanner(this.controller);
  
  @override
  List<Object> get props => [controller];
}

class ScanInventoryItem extends InventoryCheckEvent {
  final String barcode;

  const ScanInventoryItem(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class HardwareScanEvent extends InventoryCheckEvent {
  final String scannedData;

  const HardwareScanEvent(this.scannedData);

  @override
  List<Object> get props => [scannedData];
}

class CheckInventoryItem extends InventoryCheckEvent {
  final String code;

  const CheckInventoryItem(this.code);

  @override
  List<Object> get props => [code];
}

class AddToInventoryList extends InventoryCheckEvent {
  final InventoryItemEntity item;

  const AddToInventoryList(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromInventoryList extends InventoryCheckEvent {
  final String code;

  const RemoveFromInventoryList(this.code);

  @override
  List<Object> get props => [code];
}

class SaveInventoryListEvent extends InventoryCheckEvent {
  const SaveInventoryListEvent();
}

class ClearInventoryListEvent extends InventoryCheckEvent {}