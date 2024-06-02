import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/models/invoice_item.dart';
import 'package:invoice_maker/providers/auth_provider.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(fireBaseAuthProvider).currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Services')),
        body: const Center(child: Text('No user logged in')),
      );
    }

    final servicesStream = FirebaseFirestore.instance
        .collection('items')
        .where('useremail', isEqualTo: user.email)
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: StreamBuilder<QuerySnapshot>(
        stream: servicesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final services = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return InvoiceItem(
              id: doc.id,
              name: data['name'] ?? 'No name',
              description: data['description'] ?? 'No description',
              unitPrice: (data['unitPrice'] ?? 0).toDouble(),
              quantity: (data['quantity'] ?? 1) as int,
              isService: data['isService'] ?? false,
              discount: (data['discount'] ?? 0).toDouble(),
              taxApplicable: data['taxApplicable'] ?? false,
              useremail: data['useremail'] ?? '',
            );
          }).toList();

          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text(service.name),
                subtitle: Text('Unit Price: \$${service.unitPrice}\nDescription: ${service.description}'),
              );
            },
          );
        },
      ),
    );
  }
}
