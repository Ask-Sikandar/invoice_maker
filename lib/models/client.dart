import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String name;
  final String address;
  final String email;
  final String phone;

  Client({
    required this.id,
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
  });

  // Factory method to create a Client from a Firestore document snapshot
  factory Client.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Client(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
    );
  }

  // Method to convert a Client to a Firestore document map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'email': email,
      'phone': phone,
    };
  }
}
