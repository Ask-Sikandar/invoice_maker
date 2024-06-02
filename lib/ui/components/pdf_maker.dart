import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/invoice_details.dart';

Future<pw.Document> buildPdfStyle1(InvoiceDetails invoiceDetails) async {
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
      final quantity = itemData['quantity'] ?? 1; // Ensure quantity is at least 1 if not found
      final discount = itemData['discount'] ?? 0; // Default to 0 if no discount found
      final taxApplicable = itemData['taxApplicable'] ?? false; // Default to false if not found

      final itemTotal = unitPrice * quantity;
      final itemTotalWithDiscount = itemTotal * ((100 - discount) / 100);
      final itemTotalWithTax = taxApplicable
          ? itemTotalWithDiscount * ((100 + (invoiceData['taxRate'] ?? 0)) / 100)
          : itemTotalWithDiscount;

      totalWithoutTaxAndDiscount += itemTotal;
      grandTotal += itemTotalWithTax;

      items.add({
        'description': itemData['description'] ?? 'No description', // Default description if not found
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
            pw.Text(businessData['name'], style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('${businessData['address']} | ${businessData['email']} | ${businessData['phone']}',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('BILL TO', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text(clientData['name'], style: const pw.TextStyle(fontSize: 16)),
                pw.Text('${clientData['address']} | ${clientData['email']} | ${clientData['phone']}',
                    style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('INVOICE # ${invoiceDetails.invoiceData['invoiceId']}', style: const pw.TextStyle(fontSize: 16)),
                  pw.Text('INVOICE DATE ${invoiceData['createdAt'].toDate().toString().substring(0, 10)}', style: const pw.TextStyle(fontSize: 16)),
                ],
              ),
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
                pw.Text('TOTAL (Excluding tax and discount)', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('Rs. ${totalWithoutTaxAndDiscount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('GRAND TOTAL', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('Rs. ${grandTotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Thank you', style: const pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 5),
            pw.Text('Terms & Conditions', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 5),
            pw.Text('Payment is due on ${invoiceData['dueDate']}', style: const pw.TextStyle(fontSize: 16)),
          ],
        );
      },
    ),
  );

  return pdf;
}


Future<pw.Document> buildPdfStyle2(InvoiceDetails invoiceDetails) async {
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
      final quantity = itemData['quantity'] ?? 1; // Ensure quantity is at least 1 if not found
      final discount = itemData['discount'] ?? 0; // Default to 0 if no discount found
      final taxApplicable = itemData['taxApplicable'] ?? false; // Default to false if not found

      final itemTotal = unitPrice * quantity;
      final itemTotalWithDiscount = itemTotal * ((100 - discount) / 100);
      final itemTotalWithTax = taxApplicable
          ? itemTotalWithDiscount * ((100 + (invoiceData['taxRate'] ?? 0)) / 100)
          : itemTotalWithDiscount;

      totalWithoutTaxAndDiscount += itemTotal;
      grandTotal += itemTotalWithTax;

      items.add({
        'description': itemData['description'] ?? 'No description', // Default description if not found
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
            pw.Text(businessData['name'], style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            pw.Text('${businessData['address']} | ${businessData['email']} | ${businessData['phone']}',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            pw.Text('BILLED TO:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(clientData['name'], style: const pw.TextStyle(fontSize: 16)),
            pw.Text('${clientData['address']} | ${clientData['email']} | ${clientData['phone']}',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 20),
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Invoice No. ${invoiceDetails.invoiceData['invoiceId']}', style: const pw.TextStyle(fontSize: 16)),
                pw.Text('Date: ${invoiceData['createdAt'].toDate().toString().substring(0, 10)}', style: const pw.TextStyle(fontSize: 16)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Table.fromTextArray(
              headers: ['Item', 'Quantity', 'Unit Price', 'Total'],
              data: items.map((item) => [
                item['description'],
                item['quantity'].toString(),
                item['unitPrice'].toString(),
                item['total'].toString()
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal', style: pw.TextStyle(fontSize: 16)),
                pw.Text('\$${totalWithoutTaxAndDiscount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Tax (${invoiceData['taxRate']}%)', style: pw.TextStyle(fontSize: 16)),
                pw.Text('\$0.00', style: const pw.TextStyle(fontSize: 16)), // Assuming tax is not calculated here
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Total', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('\$${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Thank you!', style: const pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.Text('PAYMENT INFORMATION', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text('Bank Name: ${businessData['bankName']}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Account Name: ${businessData['accountName']}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Account No.: ${businessData['accountNumber']}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Payment Due: ${invoiceData['dueDate']}', style: const pw.TextStyle(fontSize: 12)),
          ],
        );
      },
    ),
  );

  return pdf;
}
Future<pw.Document> buildPdfStyle3(InvoiceDetails invoiceDetails) async {
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
      final quantity = itemData['quantity'] ?? 1; // Ensure quantity is at least 1 if not found
      final discount = itemData['discount'] ?? 0; // Default to 0 if no discount found
      final taxApplicable = itemData['taxApplicable'] ?? false; // Default to false if not found

      final itemTotal = unitPrice * quantity;
      final itemTotalWithDiscount = itemTotal * ((100 - discount) / 100);
      final itemTotalWithTax = taxApplicable
          ? itemTotalWithDiscount * ((100 + (invoiceData['taxRate'] ?? 0)) / 100)
          : itemTotalWithDiscount;

      totalWithoutTaxAndDiscount += itemTotal;
      grandTotal += itemTotalWithTax;

      items.add({
        'description': itemData['description'] ?? 'No description', // Default description if not found
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
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 20),
            pw.Text('BILLED TO:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(clientData['name'], style: const pw.TextStyle(fontSize: 16)),
            pw.Text('${clientData['address']} | ${clientData['email']} | ${clientData['phone']}',
                style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 20),
            pw.Text('PAY TO:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Text(businessData['name'], style: const pw.TextStyle(fontSize: 16)),
            pw.Text('${businessData['address']} | ${businessData['email']} | ${businessData['phone']}',
                style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Bank: ${businessData['bankName']}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Account Name: ${businessData['accountName']}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('BSB: ${businessData['bsb']}', style: const pw.TextStyle(fontSize: 12)),
            pw.Text('Account Number: ${businessData['accountNumber']}', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 20),
            pw.Divider(),
            pw.Table.fromTextArray(
              headers: ['Description', 'Rate', 'Hours', 'Amount'],
              data: items.map((item) => [
                item['description'],
                '\$${item['unitPrice'].toStringAsFixed(2)}/hr',
                item['quantity'].toString(),
                '\$${item['total'].toStringAsFixed(2)}'
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Sub-Total', style: pw.TextStyle(fontSize: 16)),
                pw.Text('\$${totalWithoutTaxAndDiscount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Package Discount (30%)', style: pw.TextStyle(fontSize: 16)),
                pw.Text('\$${(totalWithoutTaxAndDiscount * 0.30).toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 16)),
              ],
            ),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text('\$${grandTotal.toStringAsFixed(2)}', style:  pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Text('Payment is required within 14 business days of invoice date. Please send remittance to ${businessData['email']}.', style: const pw.TextStyle(fontSize: 12)),
            pw.SizedBox(height: 10),
            pw.Text('Thank you for your business.', style: const pw.TextStyle(fontSize: 16)),
          ],
        );
      },
    ),
  );

  return pdf;
}
