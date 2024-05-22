
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddClientScreen extends ConsumerWidget {
  final String? clientName;
  Future<dynamic> _addClient(context, String name, String email, String phone) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final clientRef = await FirebaseFirestore.instance.collection('clients').add({
        'name': name,
        'email': email,
        'phone': phone,
        'userId': user.uid,
        'createdAt': Timestamp.now(),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client added')));
      }).catchError((error){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed due to error $error')));
      });
      return clientRef;
    }
  }
  const AddClientScreen({super.key, this.clientName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientNameController = TextEditingController(text: clientName);
    final clientPhoneController = TextEditingController();
    final clientEmailController = TextEditingController();
    final clientAddressController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: clientNameController,
              decoration: const InputDecoration(labelText: 'Client Name'),
            ),
            TextField(
              controller: clientEmailController,
              decoration: const InputDecoration(labelText: 'Client Email'),
            ),
            TextField(
              controller: clientPhoneController,
              decoration: const InputDecoration(labelText: 'Client Phone'),
            ),
            TextField(
              controller: clientAddressController,
              decoration: const InputDecoration(labelText: 'Client Address'),
            ),
            // Add other client fields
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  final clientRef = await FirebaseFirestore.instance.collection('clients').add({
                    'name': clientNameController.text,
                    'email': clientEmailController.text,
                    'phone': clientPhoneController.text,
                    'useremail': user.email,
                    'createdAt': Timestamp.now(),
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client added')));
                  }).catchError((error){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed due to error $error')));
                  });
                  Navigator.pop(context, clientRef);
                }
              },
              child: const Text('Add Client'),
            ),
          ],
        ),
      ),
    );
  }
}
