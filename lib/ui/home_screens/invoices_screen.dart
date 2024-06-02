import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invoice_maker/ui/components/invoice.dart';
import 'package:invoice_maker/ui/home_screens/create_invoice_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/invoice_details.dart';
import '../../providers/invoice_provider.dart';
import '../components/pdf_maker.dart';
import 'edit_invoice_screen.dart'; // Import the new file

class InvoicesPage extends ConsumerStatefulWidget {
  const InvoicesPage({super.key});

  @override
  _InvoicesPageState createState() => _InvoicesPageState();
}

class _InvoicesPageState extends ConsumerState<InvoicesPage> {
  final invComp = InvoiceComp();
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
                            onPressed: () => invComp.showInvoiceStyleSelectionDialog(context, invoiceDetails),
                          ),
                          onTap: () => _showInvoiceDialog(context, invoiceDetails),
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
              FloatingActionButton(
                onPressed: () {
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

  void _showInvoiceDialog(BuildContext context, InvoiceDetails invoiceDetails) {
    final invoiceData = invoiceDetails.invoiceData;
    final clientData = invoiceDetails.clientData;
    final businessData = invoiceDetails.businessData;
    final TextEditingController paymentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Invoice #${invoiceDetails.id}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Client: ${clientData['name']}'),
                Text('Business: ${businessData['name']}'),
                Text('Date: ${invoiceData['createdAt'].toDate().toString().substring(0, 10)}'),
                Text('Items:'),
                ...invoiceData['items'].map<Widget>((itemId) {
                  // Fetch and display item details
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('items').doc(itemId).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text('Item not found');
                      } else {
                        final itemData = snapshot.data!.data() as Map<String, dynamic>;
                        return Text('${itemData['description']} - ${itemData['quantity']} x ${itemData['unitPrice']}');
                      }
                    },
                  );
                }).toList(),
                const SizedBox(height: 10),
                Text('Amount Paid: ${invoiceDetails.amountPaid}'),
                Text('Remaining Amount: ${invoiceDetails.remainingAmount}'),
                const SizedBox(height: 10),
                TextField(
                  controller: paymentController,
                  decoration: const InputDecoration(labelText: 'Add Payment'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add payment logic
                final double payment = double.tryParse(paymentController.text) ?? 0;
                final double newAmountPaid = invoiceDetails.amountPaid + payment;
                final double newRemainingAmount = invoiceDetails.remainingAmount - payment;

                FirebaseFirestore.instance
                    .collection('invoices')
                    .doc(invoiceDetails.id)
                    .update({
                  'amountPaid': newAmountPaid,
                  'remainingAmount': newRemainingAmount,
                })
                    .then((_) {
                  Navigator.of(context).pop();
                });
              },
              child: const Text('Add Payment'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditInvoiceScreen(invoiceDetails: invoiceDetails),
                  ),
                );
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _generatePdf(InvoiceDetails invoiceDetails, int style) async {
    pw.Document pdf;

    switch (style) {
      case 1:
        pdf = await buildPdfStyle1(invoiceDetails);
        break;
      case 2:
        pdf = await buildPdfStyle2(invoiceDetails);
        break;
      case 3:
        pdf = await buildPdfStyle3(invoiceDetails);
        break;
      default:
        pdf = await buildPdfStyle1(invoiceDetails);
    }

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}


