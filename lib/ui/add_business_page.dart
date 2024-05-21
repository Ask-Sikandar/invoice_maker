import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class AddBusinessScreen extends StatelessWidget {
  final String? businessName;

  const AddBusinessScreen({super.key, this.businessName});

  @override
  Widget build(BuildContext context) {
    final abnController = TextEditingController();
    final businessNameController = TextEditingController(text: businessName);
    final businessAddressController = TextEditingController();
    final businessEmailController = TextEditingController();
    final businessPhoneController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Business'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: abnController,
              decoration: const InputDecoration(labelText: 'ABN'),
            ),
            TextField(
              controller: businessNameController,
              decoration: const InputDecoration(labelText: 'Business Name'),
            ),
            TextField(
              controller: businessEmailController,
              decoration: const InputDecoration(labelText: 'Business Email'),
            ),
            TextField(
              controller: businessPhoneController,
              decoration: const InputDecoration(labelText: 'Business Phone'),
            ),
            TextField(
              controller: businessAddressController,
              decoration: const InputDecoration(labelText: 'Business Address'),
            ),


            // Add other business fields
            ElevatedButton(
              onPressed: () async {
                final newBusinessRef = await FirebaseFirestore.instance.collection('businesses').add({
                  'abn' : abnController.text,
                  'name': businessNameController.text,
                  'email' : businessEmailController.text,
                  'phone' : businessPhoneController.text,
                  'address' : businessAddressController.text
                }).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Business Added')));
                }).catchError((err){
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error occurred: $err')
                      ));
                });
                Navigator.pop(context, newBusinessRef);
              },
              child: const Text('Add Business'),
            ),
          ],
        ),
      ),
    );
  }
}