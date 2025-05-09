// lib/features/warehouse_scan/presentation/bloc/warehouse_out/warehouse_out_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/warehouse_out_entity.dart';

abstract class WarehouseOutState extends Equatable {
  const WarehouseOutState();

  @override
  List<Object?> get props => [];
}

class WarehouseOutInitial extends WarehouseOutState {}

class WarehouseOutScanning extends WarehouseOutState {
  final bool isCameraActive;
  final bool isTorchEnabled;
  final dynamic controller;

  const WarehouseOutScanning({
    required this.isCameraActive,
    required this.isTorchEnabled,
    this.controller,
  });

  @override
  List<Object?> get props => [isCameraActive, isTorchEnabled, controller];

  WarehouseOutScanning copyWith({
    bool? isCameraActive,
    bool? isTorchEnabled,
    dynamic controller,
  }) {
    return WarehouseOutScanning(
      isCameraActive: isCameraActive ?? this.isCameraActive,
      isTorchEnabled: isTorchEnabled ?? this.isTorchEnabled,
      controller: controller ?? this.controller,
    );
  }
}

class WarehouseOutProcessing extends WarehouseOutState {
  final String barcode;

  const WarehouseOutProcessing(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class MaterialInfoLoaded extends WarehouseOutState {
  final WarehouseOutEntity material;
  final bool quantityExceeded;
  final String? quantityError;
  final String originalAddress;

  const MaterialInfoLoaded({
    required this.material,
    this.quantityExceeded = false,
    this.quantityError,
    this.originalAddress = '',
  });

  @override
  List<Object?> get props => [material, quantityExceeded, quantityError, originalAddress];

  MaterialInfoLoaded copyWith({
    WarehouseOutEntity? material,
    bool? quantityExceeded,
    String? quantityError,
    String? originalAddress,
  }) {
    return MaterialInfoLoaded(
      material: material ?? this.material,
      quantityExceeded: quantityExceeded ?? this.quantityExceeded,
      quantityError: quantityError ?? this.quantityError,
      originalAddress: originalAddress ?? this.originalAddress,
    );
  }
}

class WarehouseOutProcessingRequest extends WarehouseOutState {
  final String code;
  final String address;
  final double quantity;

  const WarehouseOutProcessingRequest({
    required this.code,
    required this.address,
    required this.quantity,
  });

  @override
  List<Object> get props => [code, address, quantity];
}

class WarehouseOutSuccess extends WarehouseOutState {}

class WarehouseOutError extends WarehouseOutState {
  final String message;
  final WarehouseOutState previousState;
    final Map<String, dynamic>? args;

  const WarehouseOutError({
    required this.message,
    required this.previousState,
    this.args
  });

  @override
  List<Object> get props => [message, previousState, this.args!];
}