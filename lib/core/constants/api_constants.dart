class ApiConstants {
  static const String baseUrl = 'http://192.168.6.141:7053/api/';
  
  static const String loginEndpoint = 'login/auth/login';
  
  static const String homeListEndpoint = 'login/data_list/user_name';
  static const String checkCodeEndpoint = 'login/data_list/check_code';
  static const String getAddressListEndpoint = 'login/GetListAddress';
  static const String saveInventoryEndpoint = 'login/data_list/Save_GetList';
  
  static const String warehouseInEndpoint = 'warehouse_in/qc_int/warehouse_save';
  static const String warehouseOutEndpoint = 'warehouse_out/qc_int/warehouse_out_data';
  static const String batchWarehouseOutEndpoint = 'warehouse_out/qc_int/warehouse_out_batch';
  static const String warehouseImportUncheckedEndpoint = 'warehouse/pull/zc_in_qc_qty';
  static const String clearWarehouseQuantityEndpoint = 'warehouse/update/zc_warehouse_qty_int';

  static const String getListEndpoint = 'login/GetList';
  static String getListUrl(String date) => '$baseUrl$getListEndpoint?date=$date';

  static String get loginUrl => baseUrl + loginEndpoint;
  static String get homeListUrl => baseUrl + homeListEndpoint;
  static String get checkCodeUrl => baseUrl + checkCodeEndpoint;
  static String get warehouseInUrl => baseUrl + warehouseInEndpoint;
  static String get warehouseOutUrl => baseUrl + warehouseOutEndpoint;
  static String get getAddressListUrl => baseUrl + getAddressListEndpoint;
  static String get saveInventoryUrl => baseUrl + saveInventoryEndpoint;
  static String get batchWarehouseOutUrl => baseUrl + batchWarehouseOutEndpoint;
  static String get warehouseImportUncheckedUrl => baseUrl + warehouseImportUncheckedEndpoint;
  static String get clearWarehouseQuantityUrl => baseUrl + clearWarehouseQuantityEndpoint;
}