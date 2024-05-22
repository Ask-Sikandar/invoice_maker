import 'business.dart';
import 'client.dart';
import 'invoice_item.dart';

class Invoice {
  final String useremail;
  final Business businessDetails;
  final Client clientDetails;
  final List<InvoiceItem> items;
  final double taxRate; // Tax rate in percentage (0-100)

  Invoice({
    required this.useremail,
    required this.businessDetails,
    required this.clientDetails,
    required this.items,
    required this.taxRate,
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
}