import 'package:invoice_maker/models/invoice_details.dart';




class MockInvoiceDetails {
  static InvoiceDetails getInvoiceDetails() {
    return InvoiceDetails(
      id: '1',
      invoiceData: {
        'invoiceId': 'INV-0001',
        'createdAt': DateTime.now(),
        'taxRate': 10,
        'items': [
          {
            'description': 'Test Item 1',
            'unitPrice': 100.0,
            'quantity': 2,
            'discount': 0,
            'taxApplicable': true,
          },
          {
            'description': 'Test Item 2',
            'unitPrice': 50.0,
            'quantity': 1,
            'discount': 10,
            'taxApplicable': false,
          },
        ],
        'dueDate': DateTime.now().add(Duration(days: 30)),
      },
      clientData: {
        'name': 'John Doe',
        'address': '123 Main St, Springfield, USA',
        'email': 'john.doe@example.com',
        'phone': '123-456-7890',
      },
      businessData: {
        'name': 'My Business',
        'address': '456 Business St, Springfield, USA',
        'email': 'info@mybusiness.com',
        'phone': '987-654-3210',
        'bankName': 'My Bank',
        'accountName': 'Business Account',
        'accountNumber': '123456789',
        'bsb': '987-654',
      },
    );
  }
}
