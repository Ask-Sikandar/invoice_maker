import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import 'auth_provider.dart';
import '../repository/invoice_repository.dart';
import 'client_provider.dart';
import 'business_provider.dart';

final invoiceRepositoryProvider = Provider((ref) => InvoiceRepository());

final searchClientsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  final repo = ref.read(clientRepositoryProvider);
  return await repo.searchClients(query);
});

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

final addInvoiceProvider = FutureProvider.family<void, Invoice>((ref, invoice) async {
  final repo = ref.read(invoiceRepositoryProvider);
  await repo.addInvoice(invoice.toMap());
});

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
