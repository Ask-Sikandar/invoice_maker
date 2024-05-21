import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

final invoicesProvider = StreamProvider((ref) {
  return FirebaseFirestore.instance
      .collection('invoices')
      .orderBy('createdAt', descending: true)
      .snapshots();
});

class InvoicesPage extends ConsumerStatefulWidget {
  const InvoicesPage({super.key});

  @override
  _InvoicesPageState createState() => _InvoicesPageState();
}

class _InvoicesPageState extends ConsumerState<InvoicesPage> {
  final ScrollController _scrollController = ScrollController();
  final List<DocumentSnapshot> _invoices = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMoreInvoices();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _loadMoreInvoices();
      }
    });
  }

  Future<void> _loadMoreInvoices() async {
    if (_isLoading) return;
    _isLoading = true;

    Query query = FirebaseFirestore.instance
        .collection('invoices')
        .orderBy('createdAt', descending: true)
        .limit(10);

    if (_invoices.isNotEmpty) {
      query = query.startAfterDocument(_invoices.last);
    }

    final snapshot = await query.get();
    setState(() {
      _invoices.addAll(snapshot.docs);
      _isLoading = false;
    });
  }

  void _generatePdf(DocumentSnapshot invoice) async {
    final pdf = pw.Document();
    final data = invoice.data() as Map<String, dynamic>;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Invoice PDF\n\n${data['businessDetails']['name']}\n${data['clientDetails']['name']}\n...'),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
      return Consumer(
        builder: (context, watch, child) {
          final invoicesAsyncValue = ref.watch(invoicesProvider);

          return invoicesAsyncValue.when(
            data: (invoices) {
              if (invoices.docs.isEmpty && _invoices.isEmpty) {
                return const Center(child: Text('No invoices found.'));
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: _invoices.length + 1,
                itemBuilder: (context, index) {
                  if (index == _invoices.length) {
                    return _isLoading ? const Center(child: CircularProgressIndicator()) : const SizedBox.shrink();
                  }

                  final invoice = _invoices[index];
                  final data = invoice.data() as Map<String, dynamic>;

                  return ListTile(
                    title: Text(data['clientDetails']['name']),
                    subtitle: Text(data['businessDetails']['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.picture_as_pdf),
                      onPressed: () => _generatePdf(invoice),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Error: $error')),
          );
        },
      );
  }
}
