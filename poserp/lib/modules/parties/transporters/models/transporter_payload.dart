class TransporterPayload {
  final String name;
  final String phone;
  final String? vehicleNumber;
  final String? address;

  TransporterPayload({
    required this.name,
    required this.phone,
    this.vehicleNumber,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      if (vehicleNumber != null && vehicleNumber!.isNotEmpty)
        'vehicleNumber': vehicleNumber,
      if (address != null && address!.isNotEmpty) 'address': address,
    };
  }
}
