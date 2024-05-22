import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/providers/auth_provider.dart';
import '../../models/invoice_item.dart';
import '../add_business_page.dart';
import 'create_client.dart';

class AddInvoiceScreen extends ConsumerStatefulWidget {
  const AddInvoiceScreen({super.key});

  @override
  _AddInvoiceScreenState createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends ConsumerState<AddInvoiceScreen> {
  final List<InvoiceItem> _items = <InvoiceItem>[];
  final _formKey = GlobalKey<FormState>();

  final _clientController = TextEditingController();
  final _businessController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemDescController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountController = TextEditingController();
  bool _isService = false;
  bool _taxApplicable = false;
  final _taxRateController = TextEditingController();

  bool _dataChanged = false;

  void _addItem() async {
    if (_itemDescController.text.isNotEmpty &&
        _unitPriceController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _discountController.text.isNotEmpty) {
      final user = ref.read(fireBaseAuthProvider).currentUser!;
      String itemId = await _getOrCreateItem(_itemDescController.text, user.email!);

      final item = InvoiceItem(
        id: itemId,
        name: _itemNameController.text,
        description: _itemDescController.text,
        unitPrice: double.parse(_unitPriceController.text),
        quantity: int.parse(_quantityController.text),
        isService: _isService,
        discount: double.parse(_discountController.text),
        taxApplicable: _taxApplicable,
        useremail: user.email!,
      );

      setState(() {
        _items.add(item);
        _itemNameController.clear();
        _itemDescController.clear();
        _unitPriceController.clear();
        _quantityController.clear();
        _discountController.clear();
        _isService = false;
        _taxApplicable = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill all item fields'),
      ));
    }
  }

  Future<String> _getOrCreateClient(String name, String userEmail) async {
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

  Future<String> _getOrCreateBusiness(String name, String userEmail) async {
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

  Future<String> _getOrCreateItem(String description, String userEmail) async {
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
      'name': _itemNameController.text,
      'description': description,
      'unitPrice': double.parse(_unitPriceController.text),
      'discount': double.parse(_discountController.text),
      'taxApplicable': _taxApplicable,
    });

    return newItemRef.id;
  }

  Future<void> _addInvoice() async {
    final user = ref.read(fireBaseAuthProvider).currentUser!;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add at least one item'),
      ));
      return;
    }

    if (_formKey.currentState!.validate()) {
      final clientId = await _getOrCreateClient(_clientController.text, user.email!);
      final businessId = await _getOrCreateBusiness(_businessController.text, user.email!);
      final itemIds = _items.map((item) => item.id).toList();

      final invoice = {
        'useremail': user.email,
        'clientId': clientId,
        'businessId': businessId,
        'items': itemIds,
        'taxRate': double.parse(_taxRateController.text),
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance.collection('invoices').add(invoice);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice added')));
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _clientController.dispose();
    _businessController.dispose();
    _itemNameController.dispose();
    _itemDescController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    _discountController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_dataChanged) {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text('All data could be cleared. Do you want to continue?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        ),
      ) ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(fireBaseAuthProvider).currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Invoice')),
        body: const Center(child: Text('No user logged in')),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Invoice'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            onChanged: () => setState(() => _dataChanged = true),
            child: ListView(
              children: [
                const Text('Client Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return [];
                    }
                    final clients = await FirebaseFirestore.instance
                        .collection('clients')
                        .where('name', isGreaterThanOrEqualTo: textEditingValue.text)
                        .where('useremail', isEqualTo: user.email)
                        .where('name', isLessThanOrEqualTo: '${textEditingValue.text}\uf8ff')
                        .get();
                    return clients.docs.map((doc) => doc.data()['name'].toString()).toList();
                  },
                  onSelected: (String selection) {
                    _clientController.text = selection;
                  },
                  fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: fieldTextEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Client Name',
                        suffixIcon: InkWell(
                          onTap: () async {
                            final newClient = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddClientScreen(clientName: _clientController.text)),
                            );
                            if (newClient != null) {
                              _clientController.text = newClient.name;
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Add new client',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter client name' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Business Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Autocomplete<String>(
                  optionsBuilder: (TextEditingValue textEditingValue) async {
                    if (textEditingValue.text.isEmpty) {
                      return [];
                    }
                    final businesses = await FirebaseFirestore.instance
                        .collection('businesses')
                        .where('name', isGreaterThanOrEqualTo: textEditingValue.text)
                        .where('useremail', isEqualTo: user.email)
                        .where('name', isLessThanOrEqualTo: '${textEditingValue.text}\uf8ff')
                        .get();
                    return businesses.docs.map((doc) => doc.data()['name'].toString()).toList();
                  },
                  onSelected: (String selection) {
                    _businessController.text = selection;
                  },
                  fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                    return TextFormField(
                      controller: fieldTextEditingController,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        labelText: 'Business Name',
                        suffixIcon: InkWell(
                          onTap: () async {
                            final newBusiness = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddBusinessScreen(businessName: _businessController.text)),
                            );
                            if (newBusiness != null) {
                              _businessController.text = newBusiness.name;
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Add new business',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter business name' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                const Text('Item Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._items.map((item) {
                  return ListTile(
                    title: Text('${item.description} - ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}'),
                    subtitle: Text('Discount: ${item.discount}%\nTax Applicable: ${item.taxApplicable ? "Yes" : "No"}'),
                  );
                }).toList(),
                TextFormField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                  validator: (value) => value!.isEmpty && _items.isEmpty ? 'Please enter item Name' : null,
                ),
                TextFormField(
                  controller: _itemDescController,
                  decoration: const InputDecoration(labelText: 'Item Description'),
                  validator: (value) => value!.isEmpty && _items.isEmpty ? 'Please enter item description' : null,
                ),
                TextFormField(
                  controller: _unitPriceController,
                  decoration: const InputDecoration(labelText: 'Unit Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty && _items.isEmpty ? 'Please enter unit price' : null,
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty && _items.isEmpty ? 'Please enter quantity' : null,
                ),
                TextFormField(
                  controller: _discountController,
                  decoration: const InputDecoration(labelText: 'Discount (%)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty && _items.isEmpty ? 'Please enter discount' : null,
                ),
                Row(
                  children: [
                    const Text('Tax Applicable'),
                    Checkbox(
                      value: _taxApplicable,
                      onChanged: (bool? value) {
                        setState(() {
                          _taxApplicable = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _addItem,
                  child: const Text('Add Item'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _taxRateController,
                  decoration: const InputDecoration(labelText: 'Tax Rate (%)'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter tax rate' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _addInvoice,
                  child: const Text('Add Invoice'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
