import 'business.dart';
import 'client.dart';
import 'invoice_item.dart';

class Invoice {
  final String useremail;
  final Business businessDetails;
  final Client clientDetails;
  final List<InvoiceItem> items;
  final double taxRate; // Tax rate in percentage (0-100)
  final double amountPaid; // Amount already paid
  final DateTime dateOfPaymentDue; // Due date for payment

  Invoice({
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
}
