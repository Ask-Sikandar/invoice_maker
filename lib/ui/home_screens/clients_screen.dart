// lib/screens/clients_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/client_provider.dart';
import '../clients/edit_client.dart';

class ClientsScreen extends ConsumerStatefulWidget {
  const ClientsScreen({super.key});

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends ConsumerState<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _searchQuery;

  @override
  Widget build(BuildContext context) {
    final clientsStream = ref.watch(clientsProvider(_searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: clientsStream.when(
                data: (snapshot) {
                  if (snapshot.docs.isEmpty) {
                    return const Center(child: Text('No clients found.'));
                  }

                  final clients = snapshot.docs;

                  return ListView.builder(
                    itemCount: clients.length,
                    itemBuilder: (context, index) {
                      final client = clients[index].data() as Map<String, dynamic>;
                      final name = client['name'] ?? 'No name';
                      final email = client['email'] ?? 'No email';
                      final phone = client['phone'] ?? 'No phone';
                      final address = client['address'] ?? 'No address';

                      return ListTile(
                        title: Text(name),
                        subtitle: Text('Email: $email\nPhone: $phone\nAddress: $address'),
                        leading: const Icon(Icons.person),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditClientScreen(
                                  clientId: clients[index].id,
                                  name: name,
                                  email: email,
                                  phone: phone,
                                  address: address,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
