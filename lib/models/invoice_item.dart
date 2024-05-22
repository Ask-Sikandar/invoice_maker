class InvoiceItem {
  final String useremail;
  final String id;
  final String name;
  final String description;
  final double unitPrice;
  final int quantity;
  final bool isService;
  final double discount; // Discount in percentage (0-100)
  final bool taxApplicable;

  InvoiceItem({
    required this.useremail,
    required this.id,
    required this.name,
    required this.description,
    required this.unitPrice,
    required this.quantity,
    required this.isService,
    required this.discount,
    required this.taxApplicable,
  });

  double get total => unitPrice * quantity * (1 - discount / 100);
}