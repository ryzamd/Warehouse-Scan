import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final List<String> addresses;

  const AddressEntity({required this.addresses});

  @override
  List<Object?> get props => [addresses];
}