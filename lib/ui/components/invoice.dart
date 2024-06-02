import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:invoice_maker/ui/components/pdf_maker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/invoice_details.dart';

class InvoiceComp{
  Future<String> generateInvoiceId() async {
    final latestInvoiceDoc = await FirebaseFirestore.instance
        .collection('invoices')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (latestInvoiceDoc.docs.isNotEmpty && latestInvoiceDoc.docs.first.data()['invoiceId'] != null) {
      final latestInvoiceData = latestInvoiceDoc.docs.first.data();
      final latestInvoiceId = latestInvoiceData['invoiceId'] as String;
      final latestInvoiceNumber = int.parse(latestInvoiceId
          .split('-')
          .last);
      final newInvoiceNumber = latestInvoiceNumber + 1;
      return 'INV-${newInvoiceNumber.toString().padLeft(4, '0')}';
    } else {
      return 'INV-0001';
    }
  }

  void showInvoiceStyleSelectionDialog(BuildContext context, InvoiceDetails invoiceDetails) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Invoice Style'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _generatePdf(invoiceDetails, 1);
                  },
                  child: Image.asset('assets/images/invoice_samples/invoice_1.png', height: 200),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _generatePdf(invoiceDetails, 2);
                  },
                  child: Image.asset('assets/images/invoice_samples/invoice_2.png', height: 200),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _generatePdf(invoiceDetails, 3);
                  },
                  child: Image.asset('assets/images/invoice_samples/invoice_3.png', height: 200),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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