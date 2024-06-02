import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/client_provider.dart';

class AddClientScreen extends ConsumerStatefulWidget {
  final String? clientName;

  const AddClientScreen({super.key, this.clientName});

  @override
  _AddClientScreenState createState() => _AddClientScreenState();
}

class _AddClientScreenState extends ConsumerState<AddClientScreen> {
  final clientNameController = TextEditingController();
  final clientPhoneController = TextEditingController();
  final clientEmailController = TextEditingController();
  final clientAddressController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    clientNameController.text = widget.clientName ?? '';
  }

  Future<void> _addClient() async {
    setState(() {
      _isLoading = true;
    });

    final clientData = {
      'name': clientNameController.text,
      'email': clientEmailController.text,
      'phone': clientPhoneController.text,
      'address': clientAddressController.text,
    };

    try {
      await ref.read(addClientProvider(clientData).future);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Client added')));
      Navigator.pop(context, clientData);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    clientNameController.dispose();
    clientPhoneController.dispose();
    clientEmailController.dispose();
    clientAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _addClient,
              child: const Text('Add Client'),
            ),
          ],
        ),
      ),
    );
  }
}
