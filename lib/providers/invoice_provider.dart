import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice_details.dart';
import 'auth_provider.dart';
import '../../models/invoice_item.dart';
import '../repository/invoice_repository.dart';

final invoiceRepositoryProvider = Provider((ref) => InvoiceRepository());

final getClientProvider = FutureProvider.family<String, Map<String, dynamic>>((ref, params) async {
  final repo = ref.read(invoiceRepositoryProvider);
  return await repo.getOrCreateClient(params['name'], params['userEmail'], params['context']);
});

final getBusinessProvider = FutureProvider.family<String, Map<String, dynamic>>((ref, params) async {
  final repo = ref.read(invoiceRepositoryProvider);
  return await repo.getOrCreateBusiness(params['name'], params['userEmail'], params['context']);
});

final addItemProvider = FutureProvider.family<String, InvoiceItem>((ref, item) async {
  final repo = ref.read(invoiceRepositoryProvider);
  final user = ref.read(fireBaseAuthProvider).currentUser!;
  return await repo.getOrCreateItem(item.description, user.email!, item);
});

final addInvoiceProvider = FutureProvider.family<void, Map<String, dynamic>>((ref, invoice) async {
  final repo = ref.read(invoiceRepositoryProvider);
  await repo.addInvoice(invoice);
});

final invoicesProvider = StreamProvider<List<InvoiceDetails>>((ref) {
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