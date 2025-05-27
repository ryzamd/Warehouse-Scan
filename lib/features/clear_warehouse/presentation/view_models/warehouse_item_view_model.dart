import '../../domain/entities/clear_warehouse_item_entity.dart';

class WarehouseItemViewModel {
  final ClearWarehouseItemEntity? _item;
  
  WarehouseItemViewModel(this._item);
  
  factory WarehouseItemViewModel.empty() {
    return WarehouseItemViewModel(null);
  }
  
  factory WarehouseItemViewModel.fromEntity(ClearWarehouseItemEntity item) {
    return WarehouseItemViewModel(item);
  }
  
  String get displayName {
    return _item?.mName.isNotEmpty == true ? _item!.mName : 'No data';
  }
  
  String get displayProjectCode {
    return _item?.mPrjcode.isNotEmpty == true ? _item!.mPrjcode : 'No data';
  }
  
  String get displayImportMaterial {
    return _item?.zcWarehouseQtyImport.toString() ?? 'No data';
  }
  
  String get displayExportMaterial {
    return _item?.zcWarehouseQtyExport.toString() ?? 'No data';
  }
  
  String get displayTimeOfExport {
    if (_item?.zcWarehouseTimeOut == null || _item!.zcWarehouseTimeOut.isEmpty) {
      return 'No data';
    }
    return _formatDate(_item.zcWarehouseTimeOut);
  }
  
  bool get hasData => _item != null;
  
  String get itemCode => _item?.code ?? '';
  
  ClearWarehouseItemEntity? get entity => _item;
  
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'No data';
    
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}