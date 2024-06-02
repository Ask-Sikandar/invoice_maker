class InvoiceDetails {
  final String id;
  final Map<String, dynamic> invoiceData;
  final Map<String, dynamic> clientData;
  final Map<String, dynamic> businessData;
  double amountPaid;
  double remainingAmount;

  InvoiceDetails({
    required this.id,
    required this.invoiceData,
    required this.clientData,
    required this.businessData,
    this.amountPaid = 0,
    this.remainingAmount = 0,
  });
}
