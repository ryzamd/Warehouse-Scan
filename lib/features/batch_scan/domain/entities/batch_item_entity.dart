import 'package:equatable/equatable.dart';

class BatchItemEntity extends Equatable {
  final String code;
  final String name;
  final double quantity;
  final String unit;
  final bool isProcessed;
  final bool isError;
  final String errorMessage;
  final String oldAddress;
  final double quantiyImport;
  final double quantityExport;

  const BatchItemEntity({
    required this.code,
    required this.name,
    this.quantity = 0.0,
    this.unit = '',
    this.isProcessed = false,
    this.isError = false,
    this.errorMessage = '',
    this.oldAddress = '',
    this.quantiyImport = 0.0,
    this.quantityExport = 0.0,
  });

  @override
  List<Object?> get props => [code, name, quantity, unit, isProcessed, isError, errorMessage, oldAddress, quantiyImport, quantityExport];

  BatchItemEntity copyWith({
    String? code,
    String? name,
    double? quantity,
    String? unit,
    bool? isProcessed,
    bool? isError,
    String? errorMessage,
    String? oldAddress,
    double? quantiyImport,
    double? quantityExport,
  }) {
    return BatchItemEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isProcessed: isProcessed ?? this.isProcessed,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      oldAddress: oldAddress ?? this.oldAddress,
      quantiyImport: quantiyImport ?? this.quantiyImport,
      quantityExport: quantityExport ?? this.quantityExport,
    );
  }
}
