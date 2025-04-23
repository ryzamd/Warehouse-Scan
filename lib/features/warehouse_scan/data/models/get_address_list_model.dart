import 'package:warehouse_scan/features/warehouse_scan/domain/entities/get_address_list_entity.dart';

class GetAddressListModel extends GetAddressListEntity {

 const GetAddressListModel({required super.listAddress});

  factory GetAddressListModel.fromJson(List<String> json) => _$GetListAddressModelFromJson(json);

  List<String> toJson() => _$GetListAddressModelToJson(this);
}

GetAddressListModel _$GetListAddressModelFromJson(List<String> json) =>
    GetAddressListModel(
      listAddress: []
    );

List<String> _$GetListAddressModelToJson(GetAddressListModel instance) =>
    <String>[
      ...instance.listAddress
    ];