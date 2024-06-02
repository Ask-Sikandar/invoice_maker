class Business {
  final String useremail;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final String abn;

  Business({
    required this.useremail,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.abn,
  });

  factory Business.fromJson(Map<String, dynamic> json) {
    return Business(
      useremail: json['useremail'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      abn: json['abn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'useremail': useremail,
      'name': name,
      'address': address,
      'phoneNumber': phoneNumber,
      'email': email,
      'abn': abn,
    };
  }
}
