// lib/core/errors/exceptions.dart
class WarehouseException implements Exception {
  final String message;

  WarehouseException(this.message);

  @override
  String toString() => 'WarehouseException: $message';
}

class MaterialNotFoundException implements Exception {
  final String barcode;

  MaterialNotFoundException(this.barcode);

  @override
  String toString() => 'MaterialNotFoundException: No material found for barcode: $barcode';
}

class WarehouseInException implements Exception {
  final String message;

  WarehouseInException(this.message);

  @override
  String toString() => 'WarehouseInException: $message';
}

class WarehouseOutException implements Exception {
  final String message;

  WarehouseOutException(this.message);

  @override
  String toString() => 'WarehouseOutException: $message';
}