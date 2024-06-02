import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClientRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ClientRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> addClient(String name, String email, String phone, String address) async {
    final user = _auth.currentUser;
    if (user != null) {
      final existingClients = await _firestore
          .collection('clients')
          .where('email', isEqualTo: email)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (existingClients.docs.isNotEmpty) {
        throw Exception('Client with this email already exists');
      }

      await _firestore.collection('clients').add({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'userId': user.uid,
        'createdAt': Timestamp.now(),
      });
    } else {
      throw Exception('No user logged in');
    }
  }

  Stream<QuerySnapshot> getClients(String? query) {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    if (query != null && query.isNotEmpty) {
      return _firestore
          .collection('clients')
          .where('userId', isEqualTo: user.uid)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .snapshots();
    } else {
      return _firestore
          .collection('clients')
          .where('userId', isEqualTo: user.uid)
          .snapshots();
    }
  }

  Future<void> updateClient(String id, Map<String, dynamic> updatedData) async {
    await _firestore.collection('clients').doc(id).update(updatedData);
  }

  Future<List<Map<String, dynamic>>> searchClients(String query) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    final clients = await _firestore
        .collection('clients')
        .where('userId', isEqualTo: user.uid)
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
    return clients.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }
}
