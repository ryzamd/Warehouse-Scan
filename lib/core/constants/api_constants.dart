// lib/core/constants/api_constants.dart
class ApiConstants {
  // Base URL for the API
  static const String baseUrl = 'http://192.168.6.141:7053/api/';
  
  // Auth endpoints
  static const String loginEndpoint = 'login/auth/login';
  
  // Data list endpoints
  static const String homeListEndpoint = 'login/data_list/user_name';
  static const String checkCodeEndpoint = 'login/data_list/check_code';
  
  // Warehouse in endpoints
  static const String warehouseInEndpoint = 'warehouse_in/qc_int/warehouse_save';
  
  // Warehouse out endpoints
  static const String warehouseOutEndpoint = 'warehouse_out/qc_int/warehouse_out_data';

  static const String getListEndpoint = 'login/GetList';
  static String getListUrl(String date) => '$baseUrl$getListEndpoint?date=$date';
  
  // Full URLs
  static String get loginUrl => baseUrl + loginEndpoint;
  static String get homeListUrl => baseUrl + homeListEndpoint;
  static String get checkCodeUrl => baseUrl + checkCodeEndpoint;
  static String get warehouseInUrl => baseUrl + warehouseInEndpoint;
  static String get warehouseOutUrl => baseUrl + warehouseOutEndpoint;
}