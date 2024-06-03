
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:invoice_maker/models/invoice_item.dart';
class MockTextEditingController extends Mock implements TextEditingController {}

class MockFirebaseAuthProvider extends Mock {
  User? currentUser;
}

class MockAddItemProvider extends Mock {
  late Future<String> future;
}

class MockUser extends Mock implements User {
  late String email;
}

void main() {
  InvoiceItem i = InvoiceItem(
      id: 'abcd',
      name: 'screen',
      description: 'mobile ka',
      unitPrice: 45, quantity: 1,
      isService: false,
      discount: 0,
      taxApplicable: false,
      useremail: 'sikandar.6a@gmail.com');

}
