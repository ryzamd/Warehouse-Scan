import 'package:equatable/equatable.dart';
import '../../domain/entities/import_unchecked_item_entity.dart';

abstract class ImportUncheckedEvent extends Equatable {
  const ImportUncheckedEvent();

  @override
  List<Object> get props => [];
}

class InitializeScanner extends ImportUncheckedEvent {
  final dynamic controller;
  
  const InitializeScanner(this.controller);
  
  @override
  List<Object> get props => [controller];
}

class ScanImportUncheckedItem extends ImportUncheckedEvent {
  final String barcode;

  const ScanImportUncheckedItem(this.barcode);

  @override
  List<Object> get props => [barcode];
}

class HardwareScanEvent extends ImportUncheckedEvent {
  final String scannedData;

  const HardwareScanEvent(this.scannedData);

  @override
  List<Object> get props => [scannedData];
}

class CheckImportUncheckedItemEvent extends ImportUncheckedEvent {
  final String code;

  const CheckImportUncheckedItemEvent(this.code);

  @override
  List<Object> get props => [code];
}

class AddToImportUncheckedList extends ImportUncheckedEvent {
  final ImportUncheckedItemEntity item;

  const AddToImportUncheckedList(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromImportUncheckedList extends ImportUncheckedEvent {
  final String code;

  const RemoveFromImportUncheckedList(this.code);

  @override
  List<Object> get props => [code];
}

class ImportUncheckedDataEvent extends ImportUncheckedEvent {
  const ImportUncheckedDataEvent();
}

class ClearImportUncheckedListEvent extends ImportUncheckedEvent {}