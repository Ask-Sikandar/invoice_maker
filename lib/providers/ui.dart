import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/invoice.dart';
import '../models/invoice_item.dart';
import 'auth_provider.dart';

int counter = 0;
final homeScreenCounterProvider = StateProvider<int>((ref) => 0);

final invoicesProvider = StreamProvider<List<Invoice>>((ref) {
  final user = ref.watch(fireBaseAuthProvider).currentUser;
  if (user == null) {
    return const Stream.empty();
  }

  return FirebaseFirestore.instance
      .collection('invoices')
      .where('useremail', isEqualTo: user.email)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
    final List<Invoice> invoiceList = [];

    for (final doc in snapshot.docs) {
      final invoiceData = doc.data();
      final clientId = invoiceData['clientId'];
      final businessId = invoiceData['businessId'];
      final itemIds = List<String>.from(invoiceData['items']);

      final clientDoc = await FirebaseFirestore.instance.collection('clients').doc(clientId).get();
      final businessDoc = await FirebaseFirestore.instance.collection('businesses').doc(businessId).get();
      final itemsDocs = await Future.wait(itemIds.map((itemId) => FirebaseFirestore.instance.collection('items').doc(itemId).get()));

      if (clientDoc.exists && businessDoc.exists && itemsDocs.isNotEmpty) {
        final clientData = clientDoc.data()!;
        final businessData = businessDoc.data()!;
        final items = itemsDocs.map((itemDoc) => InvoiceItem.fromMap(itemDoc.data()!)).toList();

        invoiceList.add(Invoice.fromFirestore(doc.id, invoiceData, clientData, businessData, items));
      }
    }
    return invoiceList;
  });
});
