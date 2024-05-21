import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();
    _addItemController();
  }

  void _addItemController() {
    final item = InvoiceItem(
        name: _itemNameController.text,
        description: _itemDescController.text,
        unitPrice: double.parse(_unitPriceController.text),
        quantity: int.parse(_quantityController.text),
        isService: _isService,
        discount: double.parse(_discountController.text),
        taxApplicable: _taxApplicable);
    _items.add(item);
    setState(() {
      _itemNameController.clear(); // Reset the name
      _itemDescController.clear(); // Reset the description
      _unitPriceController.clear(); // Reset the unit price
      _quantityController.clear(); // Reset the quantity
      _isService = false; // Reset the service flag
      _discountController.clear(); // Reset the discount
      _taxApplicable = false; // Reset the tax applicability
    });
  }


  Future<String> _getOrCreateClient(String name) async {
    final clientQuery = await FirebaseFirestore.instance
        .collection('clients')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (clientQuery.docs.isNotEmpty) {
      return clientQuery.docs.first.id;
    }

    // If client doesn't exist, navigate to add client screen and return new client ID
    final newClientRef = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddClientScreen(clientName: name)),
    );
    return newClientRef.id;
  }

  Future<String> _getOrCreateBusiness(String name) async {
    final businessQuery = await FirebaseFirestore.instance
        .collection('businesses')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (businessQuery.docs.isNotEmpty) {
      return businessQuery.docs.first.id;
    }

    // If business doesn't exist, navigate to add business screen and return new business ID
    final newBusinessRef = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddBusinessScreen(businessName: name)),
    );
    return newBusinessRef.id;
  }

  Future<String> _getOrCreateItem(String description, int index) async {
    final itemQuery = await FirebaseFirestore.instance
        .collection('items')
        .where('description', isEqualTo: description)
        .limit(1)
        .get();

    if (itemQuery.docs.isNotEmpty) {
      final itemData = itemQuery.docs.first.data();
      setState(() {
        _unitPriceControllers[index].text = itemData['unitPrice'].toString();
        _quantityControllers[index].text = "1";
        _discountControllers[index].text = itemData['discount'].toString();
        _taxApplicableControllers[index] = itemData['taxApplicable'];
      });
      return itemQuery.docs.first.id;
    }

    // If item doesn't exist, create a new item document
    final newItemRef = await FirebaseFirestore.instance.collection('items').add({
      'description': description,
      'unitPrice': double.parse(_unitPriceControllers[index].text),
      'discount': double.parse(_discountControllers[index].text),
      'taxApplicable': _taxApplicableControllers[index],
    });

    return newItemRef.id;
  }

  Future<void> _addInvoice() async {
    if (_formKey.currentState!.validate()) {
      final clientId = await _getOrCreateClient(_clientController.text);
      final businessId = await _getOrCreateBusiness(_businessController.text);
      final itemIds = await Future.wait(
        _itemControllers.asMap().entries.map((entry) async {
          int index = entry.key;
          return await _getOrCreateItem(entry.value.text, index);
        }),
      );

      final invoice = {
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
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    for (var controller in _unitPriceControllers) {
      controller.dispose();
    }
    for (var controller in _quantityControllers) {
      controller.dispose();
    }
    for (var controller in _discountControllers) {
      controller.dispose();
    }
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
                              MaterialPageRoute(builder: (context) => AddClientScreen(clientName: _clientController.text,)),
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
                              MaterialPageRoute(builder: (context) => AddBusinessScreen(businessName: _businessController.text,)),
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
                Text('Item Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._items.map((item) {
                  return ListTile(
                    title: Text('${item.description} - ${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}'),
                    subtitle: Text('Discount: ${item.discount}%\nTax Applicable: ${item.taxApplicable ? "Yes" : "No"}'),
                  );
                }).toList(),
                const Text('Item Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ..._itemControllers.asMap().entries.map((entry) {
                  int index = entry.key;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Autocomplete<String>(
                        optionsBuilder: (TextEditingValue textEditingValue) async {
                          if (textEditingValue.text.isEmpty) {
                            return [];
                          }
                          final items = await FirebaseFirestore.instance
                              .collection('items')
                              .where('description', isGreaterThanOrEqualTo: textEditingValue.text)
                              .where('description', isLessThanOrEqualTo: '${textEditingValue.text}\uf8ff')
                              .get();
                          return items.docs.map((doc) => doc.data()['description'].toString()).toList();
                        },
                        onSelected: (String selection) {
                          _itemControllers[index].text = selection;
                          _getOrCreateItem(selection, index);
                        },
                        fieldViewBuilder: (BuildContext context, TextEditingController fieldTextEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                          return TextFormField(
                            controller: fieldTextEditingController,
                            focusNode: focusNode,
                            decoration: const InputDecoration(labelText: 'Item Description'),
                            validator: (value) => value!.isEmpty ? 'Please enter item description' : null,
                          );
                        },
                      ),
                      TextFormField(
                        controller: _unitPriceControllers[index],
                        decoration: const InputDecoration(labelText: 'Unit Price'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Please enter unit price' : null,
                      ),
                      TextFormField(
                        controller: _quantityControllers[index],
                        decoration: const InputDecoration(labelText: 'Quantity'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Please enter quantity' : null,
                      ),
                      TextFormField(
                        controller: _discountControllers[index],
                        decoration: const InputDecoration(labelText: 'Discount (%)'),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Please enter discount' : null,
                      ),
                      Row(
                        children: [
                          const Text('Tax Applicable'),
                          Checkbox(
                            value: _taxApplicableControllers[index],
                            onChanged: (bool? value) {
                              setState(() {
                                _taxApplicableControllers[index] = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _addItemController();
                    });
                  },
                  child: const Text('Add Another Item'),
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
