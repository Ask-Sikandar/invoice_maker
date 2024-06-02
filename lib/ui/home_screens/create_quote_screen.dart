import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/providers/auth_provider.dart';
import '../../models/invoice_item.dart';
import '../../models/business.dart';
import '../../models/client.dart';
import '../../models/invoice.dart';
import '../../providers/invoice_provider.dart';
import '../add_business_page.dart';
import 'create_client.dart';

class AddQuoteScreen extends ConsumerStatefulWidget {
  const AddQuoteScreen({super.key});

  @override
  _AddQuoteScreenState createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends ConsumerState<AddQuoteScreen> {
  final List<InvoiceItem> _items = <InvoiceItem>[];
  final _formKey = GlobalKey<FormState>();

  final _clientController = TextEditingController();
  final _businessController = TextEditingController();
  final _itemNameController = TextEditingController();
  final _itemDescController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _discountController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _termsController = TextEditingController();
  final _amountPaidController = TextEditingController(); // Added controller
  bool _isService = false;
  bool _taxApplicable = false;
  final _taxRateController = TextEditingController();

  bool _dataChanged = false;
  String? _selectedClientId;
  String? _selectedBusinessId;

  void _addItem() async {
    if (_itemNameController.text.isNotEmpty &&
        _itemDescController.text.isNotEmpty &&
        _unitPriceController.text.isNotEmpty &&
        _quantityController.text.isNotEmpty &&
        _discountController.text.isNotEmpty) {
      final user = ref.read(fireBaseAuthProvider).currentUser!;
      final newItem = InvoiceItem(
        id: '',
        name: _itemNameController.text,
        description: _itemDescController.text,
        unitPrice: double.parse(_unitPriceController.text),
        quantity: int.parse(_quantityController.text),
        isService: _isService,
        discount: double.parse(_discountController.text),
        taxApplicable: _taxApplicable,
        useremail: user.email!,
      );

      final itemId = await ref.read(addItemProvider(newItem).future);
      setState(() {
        _items.add(newItem.copyWith(id: itemId));
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

  Future<void> _addInvoice() async {
    final user = ref.read(fireBaseAuthProvider).currentUser!;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add at least one item'),
      ));
      return;
    }

    if (_formKey.currentState!.validate() && _selectedClientId != null && _selectedBusinessId != null) {
      final businessDoc = await FirebaseFirestore.instance.collection('businesses').doc(_selectedBusinessId).get();
      final clientDoc = await FirebaseFirestore.instance.collection('clients').doc(_selectedClientId).get();

      if (!businessDoc.exists || !clientDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid client or business selection'),
        ));
        return;
      }

      final businessData = businessDoc.data();
      final clientData = clientDoc.data();

      if (businessData == null || clientData == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error fetching client or business data'),
        ));
        return;
      }

      final business = Business.fromJson(businessData);
      final client = Client.fromMap(_selectedClientId!, clientData);

      final invoice = Invoice(
        id: '',
        useremail: user.email!,
        businessDetails: business,
        clientDetails: client,
        items: _items,
        taxRate: double.parse(_taxRateController.text),
        amountPaid: double.parse(_amountPaidController.text),
        dateOfPaymentDue: DateTime.parse(_dueDateController.text),
      );

      await ref.read(addInvoiceProvider(invoice).future);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice added')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please select a client or fill all the required fields'),
      ));
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
    _dueDateController.dispose();
    _termsController.dispose();
    _amountPaidController.dispose(); // Dispose amount paid controller
    super.dispose();
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dueDateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_dataChanged) {
      final shouldPop = await showDialog<bool>(
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
      );
      return shouldPop ?? false;
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
                Consumer(
                  builder: (context, watch, child) {
                    final searchClientState = ref.watch(searchClientsProvider(_clientController.text));
                    return searchClientState.when(
                      data: (clients) {
                        return Autocomplete<Map<String, dynamic>>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Map<String, dynamic>>.empty();
                            }
                            final List<Map<String, dynamic>> clientOptions = clients
                                .where((client) => client['name'].toString().toLowerCase().contains(textEditingValue.text.toLowerCase()))
                                .toList();

                            return clientOptions;
                          },
                          displayStringForOption: (Map<String, dynamic> option) => option['name'] as String,
                          onSelected: (Map<String, dynamic> selection) {
                            _clientController.text = selection['name'] as String;
                            _selectedClientId = selection['id'] as String;
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
                                      _selectedClientId = newClient.id;
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
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) => Center(child: Text('Error: $error')),
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
                  onSelected: (String selection) async {
                    _businessController.text = selection;
                    _selectedBusinessId = (await FirebaseFirestore.instance
                        .collection('businesses')
                        .where('name', isEqualTo: selection)
                        .where('useremail', isEqualTo: user.email)
                        .get())
                        .docs
                        .first
                        .id;
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
                }),
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
                TextFormField(
                  controller: _dueDateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Due Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => _selectDueDate(context),
                  validator: (value) => value!.isEmpty ? 'Please select due date' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _termsController,
                  decoration: const InputDecoration(labelText: 'Terms and Conditions'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountPaidController,
                  decoration: const InputDecoration(labelText: 'Amount Paid'), // Added amount paid field
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter amount paid' : null,
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
