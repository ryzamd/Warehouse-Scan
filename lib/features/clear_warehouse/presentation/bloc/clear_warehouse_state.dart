import 'package:equatable/equatable.dart';
import '../../domain/entities/clear_warehouse_item_entity.dart';

abstract class ClearWarehouseState extends Equatable {
  const ClearWarehouseState();

  @override
  List<Object?> get props => [];
}

class ClearWarehouseInitial extends ClearWarehouseState {}

class ClearWarehouseScanning extends ClearWarehouseState {
  final bool isCameraActive;
  final bool isTorchEnabled;
  final dynamic controller;
  final List<ClearWarehouseItemEntity> scannedItems;

  const ClearWarehouseScanning({
    required this.isCameraActive,
    required this.isTorchEnabled,
    this.controller,
    this.scannedItems = const [],
  });

  @override
  List<Object?> get props => [isCameraActive, isTorchEnabled, controller, scannedItems];

  ClearWarehouseScanning copyWith({
    bool? isCameraActive,
    bool? isTorchEnabled,
    dynamic controller,
    List<ClearWarehouseItemEntity>? scannedItems,
  }) {
    return ClearWarehouseScanning(
      isCameraActive: isCameraActive ?? this.isCameraActive,
      isTorchEnabled: isTorchEnabled ?? this.isTorchEnabled,
      controller: controller ?? this.controller,
      scannedItems: scannedItems ?? this.scannedItems,
    );
  }
}

class ClearWarehouseProcessing extends ClearWarehouseState {
  final String barcode;
  final List<ClearWarehouseItemEntity> scannedItems;

  const ClearWarehouseProcessing({
    required this.barcode,
    this.scannedItems = const [],
  });

  @override
  List<Object> get props => [barcode, scannedItems];
}

class ClearWarehouseItemChecked extends ClearWarehouseState {
  final ClearWarehouseItemEntity item;
  final List<ClearWarehouseItemEntity> scannedItems;

  const ClearWarehouseItemChecked({
    required this.item,
    required this.scannedItems,
  });

  @override
  List<Object> get props => [item, scannedItems];
}

class ClearWarehouseListUpdated extends ClearWarehouseState {
  final List<ClearWarehouseItemEntity> scannedItems;

  const ClearWarehouseListUpdated({required this.scannedItems});

  @override
  List<Object> get props => [scannedItems];
}

class ClearWarehouseClearing extends ClearWarehouseState {
  final String code;
  final List<ClearWarehouseItemEntity> scannedItems;

  const ClearWarehouseClearing({
    required this.code,
    required this.scannedItems,
  });

  @override
  List<Object> get props => [code, scannedItems];
}

class ClearWarehouseClearSuccess extends ClearWarehouseState {
  final String code;
  final List<ClearWarehouseItemEntity> remainingItems;

  const ClearWarehouseClearSuccess({
    required this.code,
    required this.remainingItems,
  });

  @override
  List<Object> get props => [code, remainingItems];
}

class ClearWarehouseError extends ClearWarehouseState {
  final String message;
  final ClearWarehouseState previousState;
  final Map<String, dynamic>? args;

  const ClearWarehouseError({
    required this.message,
    required this.previousState,
    this.args,
  });

  @override
  List<Object> get props => [message, previousState, args ?? {}];
}