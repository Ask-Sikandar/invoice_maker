//
// import 'package:flutter_test/flutter_test.dart';
// import 'package:invoice_maker/ui/components/pdf_maker.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// import 'pdf.dart';
//
// void main() {
//   group('PDF Generation Tests', () {
//     test('PDF Style 1 Generation', () async {
//       final invoiceDetails = MockInvoiceDetails.getInvoiceDetails();
//       final pdf = await buildPdfStyle1(invoiceDetails);
//
//       // Verify the document is not null
//       expect(pdf, isNotNull);
//       expect(pdf.pages.length, 1);
//
//       // Verify the structure
//       final page = pdf.pages[0];
//       final elements = page.getElements(pw.Context(pw.Document()));
//       expect(elements, isNotEmpty);
//     });
//
//     test('PDF Style 2 Generation', () async {
//       final invoiceDetails = MockInvoiceDetails.getInvoiceDetails();
//       final pdf = await buildPdfStyle2(invoiceDetails);
//
//       // Verify the document is not null
//       expect(pdf, isNotNull);
//       expect(pdf.pages.length, 1);
//
//       // Verify the structure
//       final page = pdf.pages[0];
//       final elements = page.getElements(pw.Context(pw.Document()));
//       expect(elements, isNotEmpty);
//     });
//
//     test('PDF Style 3 Generation', () async {
//       final invoiceDetails = MockInvoiceDetails.getInvoiceDetails();
//       final pdf = await buildPdfStyle3(invoiceDetails);
//
//       // Verify the document is not null
//       expect(pdf, isNotNull);
//       expect(pdf.pages.length, 1);
//
//   //
