import 'package:equatable/equatable.dart';
import '../../domain/entities/import_unchecked_item_entity.dart';
import '../../domain/entities/import_unchecked_response_entity.dart';

abstract class ImportUncheckedState extends Equatable {
  const ImportUncheckedState();

  @override
  List<Object?> get props => [];
}

class ImportUncheckedInitial extends ImportUncheckedState {}

class ImportUncheckedScanning extends ImportUncheckedState {
  final bool isCameraActive;
  final bool isTorchEnabled;
  final dynamic controller;
  final List<ImportUncheckedItemEntity> scannedItems;

  const ImportUncheckedScanning({
    required this.isCameraActive,
    required this.isTorchEnabled,
    this.controller,
    this.scannedItems = const [],
  });

  @override
  List<Object?> get props => [isCameraActive, isTorchEnabled, controller, scannedItems];

  ImportUncheckedScanning copyWith({
    bool? isCameraActive,
    bool? isTorchEnabled,
    dynamic controller,
    List<ImportUncheckedItemEntity>? scannedItems,
  }) {
    return ImportUncheckedScanning(
      isCameraActive: isCameraActive ?? this.isCameraActive,
      isTorchEnabled: isTorchEnabled ?? this.isTorchEnabled,
      controller: controller ?? this.controller,
      scannedItems: scannedItems ?? this.scannedItems,
    );
  }
}

class ImportUncheckedProcessing extends ImportUncheckedState {
  final String barcode;
  final List<ImportUncheckedItemEntity> scannedItems;

  const ImportUncheckedProcessing({
    required this.barcode,
    this.scannedItems = const [],
  });

  @override
  List<Object> get props => [barcode, scannedItems];
}

class ImportUncheckedItemChecked extends ImportUncheckedState {
  final ImportUncheckedItemEntity item;
  final List<ImportUncheckedItemEntity> scannedItems;

  const ImportUncheckedItemChecked({
    required this.item,
    required this.scannedItems,
  });

  @override
  List<Object> get props => [item, scannedItems];
}

class ImportUncheckedListUpdated extends ImportUncheckedState {
  final List<ImportUncheckedItemEntity> scannedItems;

  const ImportUncheckedListUpdated({required this.scannedItems});

  @override
  List<Object> get props => [scannedItems];
}

class ImportUncheckedPulling extends ImportUncheckedState {
  final List<ImportUncheckedItemEntity> scannedItems;

  const ImportUncheckedPulling({required this.scannedItems});

  @override
  List<Object> get props => [scannedItems];
}

class ImportUncheckedPullSuccess extends ImportUncheckedState {
  final ImportUncheckedResponseEntity response;
  final int successCount;
  final int failedCount;

  const ImportUncheckedPullSuccess({
    required this.response,
    required this.successCount,
    required this.failedCount,
  });

  @override
  List<Object> get props => [response, successCount, failedCount];
}

class ImportUncheckedError extends ImportUncheckedState {
  final String message;
  final ImportUncheckedState previousState;
  final Map<String, dynamic>? args;

  const ImportUncheckedError({
    required this.message,
    required this.previousState,
    this.args,
  });

  @override
  List<Object> get props => [message, previousState, args ?? {}];
}