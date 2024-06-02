import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invoice_maker/ui/home_screens/create_invoice_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../models/invoice_details.dart';
import '../../providers/invoice_provider.dart';

class QuotesScreen extends ConsumerStatefulWidget {
  const QuotesScreen({super.key});

  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends ConsumerState<QuotesScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      body: Column(
        children: [

          Expanded(
            child: Consumer(
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
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddInvoiceScreen()));
              },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ],
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
                  pw.Text('INVOICE # ${invoiceDetails.id}', style: const pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(clientData['name'], style: const pw.TextStyle(fontSize: 16)),
                  pw.Text('INVOICE DATE ${invoiceData['createdAt'].toDate().toString().substring(0, 10)}', style: const pw.TextStyle(fontSize: 16)),
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
                  pw.Text('₨${totalWithoutTaxAndDiscount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GRAND TOTAL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('₨${grandTotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Thank you', style: const pw.TextStyle(fontSize: 16)),
              pw.SizedBox(height: 5),
              pw.Text('Terms & Conditions', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text('Payment is due within 15 days', style: const pw.TextStyle(fontSize: 16)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
