

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/invoice_details.dart';
import 'auth_provider.dart';

int counter = 0;
final homeScreenCounterProvider = StateProvider<int>((ref) => 0);
final invoicesProvider = StreamProvider((ref) {
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
    final List<InvoiceDetails> invoiceDetailsList = [];

    for (final doc in snapshot.docs) {
      final invoiceData = doc.data();
      final clientId = invoiceData['clientId'];
      final businessId = invoiceData['businessId'];

      final clientDoc = await FirebaseFirestore.instance.collection('clients').doc(clientId).get();
      final businessDoc = await FirebaseFirestore.instance.collection('businesses').doc(businessId).get();

      if (clientDoc.exists && businessDoc.exists) {
        final clientData = clientDoc.data()!;
        final businessData = businessDoc.data()!;
        print(invoiceData);
        invoiceDetailsList.add(InvoiceDetails(
          id: doc.id,
          invoiceData: invoiceData,
          clientData: clientData,
          businessData: businessData,
        ));
      }
    }
    return invoiceDetailsList;
  });
});
