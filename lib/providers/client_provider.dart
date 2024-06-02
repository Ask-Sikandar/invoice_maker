// lib/providers/client_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/client_repository.dart';

final clientRepositoryProvider = Provider<ClientRepository>((ref) {
  return ClientRepository();
});

final clientsProvider = StreamProvider.autoDispose.family<QuerySnapshot, String?>((ref, query) {
  final repository = ref.watch(clientRepositoryProvider);
  return repository.getClients(query);
});

final updateClientProvider = FutureProvider.autoDispose.family<void, Map<String, dynamic>>((ref, clientData) async {
  final repository = ref.watch(clientRepositoryProvider);
  await repository.updateClient(
    clientData['id'],
    clientData['data'],
  );
});

final addClientProvider = FutureProvider.autoDispose.family<void, Map<String, String>>((ref, clientData) async {
  final repository = ref.watch(clientRepositoryProvider);
  await repository.addClient(
    clientData['name']!,
    clientData['email']!,
    clientData['phone']!,
    clientData['address']!,
  );
});
final searchClientsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  final repository = ref.watch(clientRepositoryProvider);
  return await repository.searchClients(query);
});