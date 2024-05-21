import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invoice_maker/models/business.dart';

class BusinessRepository{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addBusiness(Business business) async {
    try {
      await _firestore.collection('businesses').add(business.toJson());
    } catch (e) {
      print('Error adding business: $e');
      rethrow;
    }
  }
  Future<List<Business>> fetchBusinesses() async {
    // Example API call
    // Replace this with your actual API call
    await Future.delayed(const Duration(seconds: 1)); // Simulating network delay
    return [
      Business(name: 'Business 1', address: 'Address 1', phoneNumber: '12345', email: 'email1@example.com', abn: '123'),
      Business(name: 'Business 2', address: 'Address 2', phoneNumber: '67890', email: 'email2@example.com', abn: '123'),
    ];
  }
}