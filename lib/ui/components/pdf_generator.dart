import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../models/invoice.dart';

class InvoicePdfGenerator {
  Future<void> generatePdf(Invoice invoice) async {
    final pdf = pw.Document();

    // Calculate totals
    double totalWithoutTaxAndDiscount = 0;
    double grandTotal = 0;

    final items = <Map<String, dynamic>>[];
    for (var item in invoice.items) {
      final unitPrice = item.unitPrice;
      final quantity = item.quantity;
      final discount = item.discount;
      final taxApplicable = item.taxApplicable;

      final itemTotal = unitPrice * quantity;
      final itemTotalWithDiscount = itemTotal * ((100 - discount) / 100);
      final itemTotalWithTax = taxApplicable
          ? itemTotalWithDiscount * ((100 + invoice.taxRate) / 100)
          : itemTotalWithDiscount;

      totalWithoutTaxAndDiscount += itemTotal;
      grandTotal += itemTotalWithTax;

      items.add({
        'description': item.description,
        'unitPrice': unitPrice,
        'quantity': quantity,
        'total': itemTotal,
      });
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
                  pw.Text('INVOICE # ${invoice.useremail}', style: const pw.TextStyle(fontSize: 16)),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(invoice.clientDetails.name, style: const pw.TextStyle(fontSize: 16)),
                  pw.Text('INVOICE DATE ${invoice.dateOfPaymentDue.toString().substring(0, 10)}', style: const pw.TextStyle(fontSize: 16)),
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
