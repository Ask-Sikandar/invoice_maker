class Business {
  String name;
  String address;
  String phoneNumber;
  String email;
  String abn; // Added ABN field

  Business({
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.abn, // Added ABN field
  });

  // Factory constructor for creating a Business object from a map
  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      abn: json['abn'], // Added ABN field
    );
  }

  // Method to convert Business object to a map
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'abn': abn, // Added ABN field
    };
  }

  @override
  String toString() {
    return 'Business{name: $name, address: $address, phoneNumber: $phoneNumber, email: $email, abn: $abn}';
  }
}