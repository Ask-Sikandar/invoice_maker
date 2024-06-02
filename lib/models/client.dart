import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String useremail;
  final String name;
  final String address;
  final String email;
  final String phone;

  Client({
    required this.id,
    required this.useremail,
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
  });

  factory Client.fromMap(String id, Map<String, dynamic> data) {
    return Client(
      id: id,
      useremail: data['useremail'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'useremail': useremail,
      'name': name,
      'address': address,
      'email': email,
      'phone': phone,
    };
  }
}
