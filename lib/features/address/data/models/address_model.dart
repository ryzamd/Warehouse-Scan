import '../../domain/entities/address_entity.dart';

class AddressModel extends AddressEntity {
  const AddressModel({required super.addresses});

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final addressList = (json['addressList'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    
    return AddressModel(addresses: addressList);
  }

  Map<String, dynamic> toJson() => {
    'addressList': addresses,
  };
}