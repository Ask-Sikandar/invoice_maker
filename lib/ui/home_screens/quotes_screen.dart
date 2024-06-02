import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:invoice_maker/ui/home_screens/create_invoice_screen.dart';
import '../../models/invoice.dart';
import '../../providers/invoice_provider.dart';
import '../components/pdf_generator.dart';

class QuotesScreen extends ConsumerStatefulWidget {
  const QuotesScreen({super.key});

  @override
  _QuotesScreenState createState() => _QuotesScreenState();
}

class _QuotesScreenState extends ConsumerState<QuotesScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedInvoices = {};

  void _showEditDialog(Invoice invoice) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController amountController = TextEditingController(text: invoice.amountPaid.toString());
        final TextEditingController dueDateController = TextEditingController(text: invoice.dateOfPaymentDue.toString().substring(0, 10));

        return AlertDialog(
          title: const Text('Edit Invoice'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount Paid'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date'),
                keyboardType: TextInputType.datetime,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('invoices')
                    .doc(invoice.id)
                    .update({
                  'amountPaid': double.parse(amountController.text),
                  'dueDate': Timestamp.fromDate(DateTime.parse(dueDateController.text)),
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _selectedInvoices.isEmpty ? null : _deleteSelectedInvoices,
          ),
        ],
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
                        final invoice = invoices[index];
                        final clientData = invoice.clientDetails;
                        final businessData = invoice.businessDetails;
                        final isSelected = _selectedInvoices.contains(invoice.id);

                        return ListTile(
                          title: Text('Client: ${clientData.name}'),
                          subtitle: Text('Business: ${businessData.name}'),
                          leading: Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedInvoices.add(invoice.id);
                                } else {
                                  _selectedInvoices.remove(invoice.id);
                                }
                              });
                            },
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(invoice),
                              ),
                              IconButton(
                                icon: const Icon(Icons.picture_as_pdf),
                                onPressed: () => InvoicePdfGenerator().generatePdf(invoice),
                              ),
                            ],
                          ),
                          onTap: () => _showEditDialog(invoice),
                          tileColor: invoice.amountPaid >= invoice.total ? Colors.green.shade100 : null,
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

  void _deleteSelectedInvoices() {
    for (String invoiceId in _selectedInvoices) {
      FirebaseFirestore.instance.collection('invoices').doc(invoiceId).delete();
    }
    setState(() {
      _selectedInvoices.clear();
    });
  }
}
