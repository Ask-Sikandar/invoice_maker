import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/providers/ui.dart';
import 'package:invoice_maker/ui/components/home_page_icon_buttons.dart';
import 'package:invoice_maker/ui/home_screens/create_invoice_screen.dart';
import 'package:invoice_maker/ui/home_screens/profile_page.dart';
import '../../providers/auth_provider.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<Home> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {

  @override
  Widget build(BuildContext) {
    final data = ref.watch(fireBaseAuthProvider);
    return GridView.count(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      scrollDirection: Axis.vertical,
      children: [
        HomePageIconButtons(onPressed: () {
          ref
              .read(homeScreenCounterProvider.notifier)
              .state = 1;
        },
          icon: const Icon(CupertinoIcons.doc_text_fill), label: 'Invoices',),
        HomePageIconButtons(onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const AddInvoiceScreen()));
        }, icon: const Icon(CupertinoIcons.doc_text), label: 'New Invoice'),
        HomePageIconButtons(onPressed: () {}, icon: const Icon(CupertinoIcons.chart_pie), label: 'Quotes'),
        HomePageIconButtons(onPressed: () {}, icon: const Icon(CupertinoIcons.add_circled), label: 'New Quote'),
        HomePageIconButtons(onPressed: () {
          ref.read(homeScreenCounterProvider.notifier).state = 2;
        }, icon: const Icon(Icons.people), label: 'Clients'),
        HomePageIconButtons(onPressed: () {
          ref.read(homeScreenCounterProvider.notifier).state = 3;
        }, icon: const Icon(Icons.inventory), label: 'Products/Services'),
        HomePageIconButtons(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage())), icon: const Icon(Icons.person),
            label: data.currentUser!.displayName ?? 'Profile'),
        HomePageIconButtons(onPressed: () {}, icon: const Icon(Icons.settings), label: 'Settings')
      ],
    );
  }
}