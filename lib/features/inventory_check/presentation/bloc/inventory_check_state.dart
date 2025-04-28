// lib/features/inventory_check/presentation/bloc/inventory_check_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/inventory_item_entity.dart';

abstract class InventoryCheckState extends Equatable {
  const InventoryCheckState();

  @override
  List<Object?> get props => [];
}

class InventoryCheckInitial extends InventoryCheckState {}

class InventoryCheckScanning extends InventoryCheckState {
  final bool isCameraActive;
  final bool isTorchEnabled;
  final dynamic controller;
  final List<InventoryItemEntity> scannedItems;

  const InventoryCheckScanning({
    required this.isCameraActive,
    required this.isTorchEnabled,
    this.controller,
    this.scannedItems = const [],
  });

  @override
  List<Object?> get props => [isCameraActive, isTorchEnabled, controller, scannedItems];

  InventoryCheckScanning copyWith({
    bool? isCameraActive,
    bool? isTorchEnabled,
    dynamic controller,
    List<InventoryItemEntity>? scannedItems,
  }) {
    return InventoryCheckScanning(
      isCameraActive: isCameraActive ?? this.isCameraActive,
      isTorchEnabled: isTorchEnabled ?? this.isTorchEnabled,
      controller: controller ?? this.controller,
      scannedItems: scannedItems ?? this.scannedItems,
    );
  }
}

class InventoryCheckProcessing extends InventoryCheckState {
  final String barcode;
  final List<InventoryItemEntity> scannedItems;

  const InventoryCheckProcessing({
    required this.barcode,
    this.scannedItems = const [],
  });

  @override
  List<Object> get props => [barcode, scannedItems];
}

class InventoryItemChecked extends InventoryCheckState {
  final InventoryItemEntity item;
  final List<InventoryItemEntity> scannedItems;

  const InventoryItemChecked({
    required this.item,
    required this.scannedItems,
  });

  @override
  List<Object> get props => [item, scannedItems];
}

class InventoryListUpdated extends InventoryCheckState {
  final List<InventoryItemEntity> scannedItems;

  const InventoryListUpdated({required this.scannedItems});

  @override
  List<Object> get props => [scannedItems];
}

class InventorySaving extends InventoryCheckState {
  final List<InventoryItemEntity> scannedItems;

  const InventorySaving({required this.scannedItems});

  @override
  List<Object> get props => [scannedItems];
}

class InventorySaveSuccess extends InventoryCheckState {
  final List<InventoryItemEntity> savedItems;

  const InventorySaveSuccess({required this.savedItems});

  @override
  List<Object> get props => [savedItems];
}

class InventoryCheckError extends InventoryCheckState {
  final String message;
  final InventoryCheckState previousState;

  const InventoryCheckError({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object> get props => [message, previousState];
}