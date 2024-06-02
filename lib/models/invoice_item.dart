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

  InvoiceItem copyWith({
    String? id,
    String? name,
    String? description,
    double? unitPrice,
    int? quantity,
    bool? isService,
    double? discount,
    bool? taxApplicable,
    String? useremail,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      isService: isService ?? this.isService,
      discount: discount ?? this.discount,
      taxApplicable: taxApplicable ?? this.taxApplicable,
      useremail: useremail ?? this.useremail,
    );
  }

  double get total => unitPrice * quantity * (1 - discount / 100);

  factory InvoiceItem.fromMap(Map<String, dynamic> data) {
    return InvoiceItem(
      useremail: data['useremail'],
      id: data['id'],
      name: data['name'],
      description: data['description'],
      unitPrice: data['unitPrice'],
      quantity: data['quantity'],
      isService: data['isService'],
      discount: data['discount'],
      taxApplicable: data['taxApplicable'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'useremail': useremail,
      'id': id,
      'name': name,
      'description': description,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'isService': isService,
      'discount': discount,
      'taxApplicable': taxApplicable,
    };
  }
}
