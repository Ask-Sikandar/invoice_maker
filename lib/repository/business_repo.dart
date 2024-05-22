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
}