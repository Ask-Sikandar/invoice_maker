import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invoice_maker/providers/auth_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

class InvoiceDetails {
  final String id;
  final Map<String, dynamic> invoiceData;
  final Map<String, dynamic> clientData;
  final Map<String, dynamic> businessData;

  InvoiceDetails({
    required this.id,
    required this.invoiceData,
    required this.clientData,
    required this.businessData,
  });
}

class InvoicesPage extends ConsumerStatefulWidget {
  const InvoicesPage({super.key});

  @override
  _InvoicesPageState createState() => _InvoicesPageState();
}

class _InvoicesPageState extends ConsumerState<InvoicesPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final invoicesAsyncValue = ref.watch(invoicesProvider);

          return invoicesAsyncValue.when(
            data: (invoices) {
              if (invoices.isEmpty) {
                return const Center(child: Text('No invoices found.'));
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final invoiceDetails = invoices[index];
                  final invoiceData = invoiceDetails.invoiceData;
                  final clientData = invoiceDetails.clientData;
                  final businessData = invoiceDetails.businessData;

                  return ListTile(
                    title: Text('Client: ${clientData['name']}'),
                    subtitle: Text('Business: ${businessData['name']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () => _generatePdf(invoiceDetails),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          );
        },
      ),
    );
  }

  void _generatePdf(InvoiceDetails invoiceDetails) async {
    final pdf = pw.Document();
    final invoiceData = invoiceDetails.invoiceData;
    final clientData = invoiceDetails.clientData;
    final businessData = invoiceDetails.businessData;

    // Calculate totals
    double totalWithoutTaxAndDiscount = 0;
    double grandTotal = 0;

    final items = <Map<String, dynamic>>[];
    for (String itemId in invoiceData['items']) {
      final itemDoc = await FirebaseFirestore.instance.collection('items').doc(itemId).get();
      if (itemDoc.exists) {
        final itemData = itemDoc.data()!;
        final unitPrice = itemData['unitPrice'] ?? 0;
        final quantity = itemData['quantity'] ?? 0;
        final discount = itemData['discount'];
        final taxApplicable = itemData['taxApplicable'];

        final itemTotal = unitPrice * quantity;
        final itemTotalWithDiscount = itemTotal * ((100 - discount) / 100);
        final itemTotalWithTax = taxApplicable
            ? itemTotalWithDiscount * ((100 + invoiceData['taxRate']) / 100)
            : itemTotalWithDiscount;

        totalWithoutTaxAndDiscount += itemTotal;
        grandTotal += itemTotalWithTax;

        items.add({
          'description': itemData['description'],
          'unitPrice': unitPrice,
          'quantity': quantity,
          'total': itemTotal,
        });
      }
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('IBA', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('BILL TO', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('INVOICE # ${invoiceDetails.id}', style: pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(clientData['name'], style: pw.TextStyle(fontSize: 16)),
                  pw.Text('INVOICE DATE ${invoiceData['createdAt'].toDate().toString().substring(0, 10)}', style: pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('DESCRIPTION', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Table.fromTextArray(
                headers: ['Description', 'Unit Price', 'Quantity', 'Total'],
                data: items.map((item) => [
                  item['description'],
                  item['unitPrice'].toString(),
                  item['quantity'].toString(),
                  item['total'].toString()
                ]).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL(Excluding tax and discount)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('₨${totalWithoutTaxAndDiscount.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GRAND TOTAL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('₨${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Thank you', style: pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 5),
              pw.Text('Terms & Conditions', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text('Payment is due within 15 days', style: pw.TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
