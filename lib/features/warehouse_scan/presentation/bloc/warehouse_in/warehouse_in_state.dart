// lib/features/warehouse_scan/presentation/bloc/warehouse_in/warehouse_in_state.dart
import 'package:equatable/equatable.dart';
import '../../../domain/entities/warehouse_in_entity.dart';

abstract class WarehouseInState extends Equatable {
  const WarehouseInState();

  @override
  List<Object?> get props => [];
}

class WarehouseInInitial extends WarehouseInState {}

class WarehouseInScanning extends WarehouseInState {
  final bool isCameraActive;
  final bool isTorchEnabled;
  final dynamic controller;  // Using dynamic to avoid import conflicts

  const WarehouseInScanning({
    required this.isCameraActive,
    required this.isTorchEnabled,
    this.controller,
  });

  @override
  List<Object?> get props => [isCameraActive, isTorchEnabled, controller];

  WarehouseInScanning copyWith({
    bool? isCameraActive,
    bool? isTorchEnabled,
    dynamic controller,
  }) {
    return WarehouseInScanning(
      isCameraActive: isCameraActive ?? this.isCameraActive,
      isTorchEnabled: isTorchEnabled ?? this.isTorchEnabled,
      controller: controller ?? this.controller,
    );
  }
}

class WarehouseInProcessing extends WarehouseInState {
  final String barcode;

  const WarehouseInProcessing(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class WarehouseInSuccess extends WarehouseInState {
  final WarehouseInEntity data;

  const WarehouseInSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class WarehouseInError extends WarehouseInState {
  final String message;
  final WarehouseInState previousState;

  const WarehouseInError({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object> get props => [message, previousState];
}