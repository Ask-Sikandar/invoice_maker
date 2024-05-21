import 'package:flutter/material.dart';



class AddItem extends StatefulWidget {
  const AddItem({super.key});

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController itemName = TextEditingController();
  TextEditingController itemPrice = TextEditingController();
  TextEditingController itemQuantity = TextEditingController();
  TextEditingController discountPercentage = TextEditingController();
  TextEditingController taxRate = TextEditingController();
  double amount = 0;
  TextEditingController desc = TextEditingController();

  double calculateTotal(){
    final gross = double.parse(itemPrice.text) * double.parse(itemQuantity.text);
    final adjustments =  double.parse(taxRate.text)*gross - double.parse(discountPercentage.text)/100*gross;
    setState(() {
      amount = gross + adjustments;
    });
    return gross + adjustments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            const Text('Item Name'),
            Row(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                      labelText: 'Enter service or product name',
                      suffixText: '*',
                      suffixStyle: TextStyle(
                        color: Colors.red,
                      )
                  ),
                ),
                ElevatedButton(onPressed: () {}, child: const Text('Add'))
              ],
            ),
            const Text('Item Price'),
            TextFormField(
              initialValue: '0.00',
              decoration: const InputDecoration(
                  suffixText: '*',
                  suffixStyle: TextStyle(
                    color: Colors.red,
                  )
              ),
            ),
            const Text('Item Quantity'),
            TextFormField(
              initialValue: '1',
              controller: itemQuantity,
              decoration: const InputDecoration(
                  labelText: ''
              ),
            ),
            const Text('Discount Percentage'),
            TextFormField(
              initialValue: '0.00',
              decoration: const InputDecoration(
                  labelText: ''
              ),
            ),
            const Text('Individual Tax Rate'),
            TextFormField(
              initialValue: '0.00',
              decoration: const InputDecoration(
              ),
            ),
            const Text('Amount'),
            TextFormField(
              enabled: false,
              initialValue: amount.toString(),
              decoration: const InputDecoration(
                  labelText: ''
              ),
            ),
            const Text('Item Description'),
            TextField(
              controller: desc,
              decoration: const InputDecoration(
                  labelText: 'Description'
              ),
            ),
          ],
        ),
      ),
    );
  }
}