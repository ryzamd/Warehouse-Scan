class BatchProcessRequestModel {
  final String code;
  final String userName;
  final String address;
  final double qty;
  final int number;

  BatchProcessRequestModel({
    required this.code,
    required this.userName,
    required this.address,
    required this.qty,
    required this.number,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'userName': userName,
      'address': address,
      'qty': qty,
      'number': number,
    };
  }
}