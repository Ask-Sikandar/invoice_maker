import 'package:cloud_firestore/cloud_firestore.dart';

import 'business.dart';
import 'client.dart';
import 'invoice_item.dart';

class Invoice {
  final String id;
  final String useremail;
  final Business businessDetails;
  final Client clientDetails;
  final List<InvoiceItem> items;
  final double taxRate;
  final double amountPaid;
  final DateTime dateOfPaymentDue;

  Invoice({
    required this.id,
    required this.useremail,
    required this.businessDetails,
    required this.clientDetails,
    required this.items,
    required this.taxRate,
    required this.amountPaid,
    required this.dateOfPaymentDue,
  });

  double get subtotal {
    return items.fold(0, (sum, item) => sum + item.total);
  }

  double get tax {
    return subtotal * (taxRate / 100);
  }

  double get total {
    return subtotal + tax;
  }

  double get amountRemaining {
    return total - amountPaid;
  }

  factory Invoice.fromFirestore(String id, Map<String, dynamic> invoiceData, Map<String, dynamic> clientData, Map<String, dynamic> businessData, List<InvoiceItem> items) {
    return Invoice(
      id: id,
      useremail: invoiceData['useremail'] ?? '',
      businessDetails: Business.fromJson(businessData),
      clientDetails: Client.fromMap(id, clientData),
      items: items,
      taxRate: (invoiceData['taxRate'] ?? 0).toDouble(),
      amountPaid: (invoiceData['amountPaid'] ?? 0).toDouble(),
      dateOfPaymentDue: (invoiceData['dueDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'useremail': useremail,
      'businessDetails': businessDetails.toJson(),
      'clientDetails': clientDetails.toMap(),
      'items': items.map((item) => item.toMap()).toList(),
      'taxRate': taxRate,
      'amountPaid': amountPaid,
      'dueDate': dateOfPaymentDue,
    };
  }
}
