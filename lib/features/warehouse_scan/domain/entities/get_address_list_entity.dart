import 'package:equatable/equatable.dart';

class GetAddressListEntity extends Equatable {
  final List<String> listAddress;

  const GetAddressListEntity({required this.listAddress});

  @override

  List<Object?> get props => [listAddress];
}