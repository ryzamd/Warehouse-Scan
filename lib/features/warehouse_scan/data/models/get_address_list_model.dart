import 'package:warehouse_scan/features/warehouse_scan/domain/entities/get_address_list_entity.dart';

class GetAddressListModel extends GetAddressListEntity {
  const GetAddressListModel({required super.listAddress});

  factory GetAddressListModel.fromJson(Map<String, dynamic> json) {
    final addressList = (json['addressList'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    
    return GetAddressListModel(listAddress: addressList);
  }

  Map<String, dynamic> toJson() => {
    'addressList': listAddress,
  };
}