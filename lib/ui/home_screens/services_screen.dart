import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products and Services'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('items')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No products or services found.'));
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index].data() as Map<String, dynamic>;
              final description = item['description'] ?? 'No description';
              final unitPrice = item['unitPrice']?.toString() ?? 'No price';
              final isService = item['isService'] ?? false;
              final discount = item['discount']?.toString() ?? 'No discount';
              final taxApplicable = item['taxApplicable'] ?? false;

              return ListTile(
                title: Text(description),
                subtitle: Text('Price: $unitPrice\nDiscount: $discount%\nTax Applicable: ${taxApplicable ? "Yes" : "No"}'),
                trailing: isService ? const Icon(Icons.miscellaneous_services) : const Icon(Icons.shopping_bag),
              );
            },
          );
        },
      ),
    );
  }
}
