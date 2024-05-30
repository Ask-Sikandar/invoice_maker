import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/invoice_item.dart';
import '../ui/add_business_page.dart';
import '../ui/home_screens/create_client.dart';

class InvoiceRepository {
  Future<String> getOrCreateClient(String name, String userEmail, BuildContext context) async {
    final clientQuery = await FirebaseFirestore.instance
        .collection('clients')
        .where('name', isEqualTo: name)
        .where('useremail', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (clientQuery.docs.isNotEmpty) {
      return clientQuery.docs.first.id;
    }

    final newClientRef = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddClientScreen(clientName: name)),
    );
    return newClientRef.id;
  }

  Future<String> getOrCreateBusiness(String name, String userEmail, BuildContext context) async {
    final businessQuery = await FirebaseFirestore.instance
        .collection('businesses')
        .where('name', isEqualTo: name)
        .where('useremail', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (businessQuery.docs.isNotEmpty) {
      return businessQuery.docs.first.id;
    }

    final newBusinessRef = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddBusinessScreen(businessName: name)),
    );
    return newBusinessRef.id;
  }

  Future<String> getOrCreateItem(String description, String userEmail, InvoiceItem item) async {
    final itemQuery = await FirebaseFirestore.instance
        .collection('items')
        .where('description', isEqualTo: description)
        .where('useremail', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (itemQuery.docs.isNotEmpty) {
      return itemQuery.docs.first.id;
    }

    final newItemRef = await FirebaseFirestore.instance.collection('items').add({
      'useremail': userEmail,
      'name': item.name,
      'description': description,
      'unitPrice': item.unitPrice,
      'discount': item.discount,
      'taxApplicable': item.taxApplicable,
    });

    return newItemRef.id;
  }

  Future<void> addInvoice(Map<String, dynamic> invoice) async {
    await FirebaseFirestore.instance.collection('invoices').add(invoice);
  }
}
