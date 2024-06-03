import 'package:flutter/cupertino.dart';
import 'package:invoice_maker/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/providers/ui.dart';
import 'home_screens/clients_screen.dart';
import 'home_screens/home.dart';
import 'home_screens/invoices_screen.dart';
import 'home_screens/more_pages.dart';
import 'home_screens/services_screen.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static final List<Widget> _homePages = <Widget>[
    const Home(),
    const InvoicesPage(),
    const ClientsScreen(),
    const ServicesScreen(),
    const MorePage(),
  ];

  List<String> pages = ['Home', 'Invoices', 'Clients', 'Services/Products', 'More'];
  void _showLogoutConfirmation(BuildContext context) {
    final auth = ref.watch(authRepositoryProvider);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () {
                auth.signOut();
                // Perform the logout operation here
              },
            ),
          ],
        );
      },
    );
  }

    @override
    Widget build(BuildContext context) {
      void onItemTapped(int index){
        ref.read(homeScreenCounterProvider.notifier).state = index;
      }

      final data = ref.watch(fireBaseAuthProvider);
      final counter = ref.watch(homeScreenCounterProvider);

      final auth = ref.watch(authRepositoryProvider);
      return Scaffold(
        appBar: AppBar(
          title: const Text('Invoice Maker'),
          actions: [
            IconButton(onPressed: () {
              _showLogoutConfirmation(context);
            }, icon: const Icon(Icons.logout))
          ],
        ),
        body: Center(
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: _homePages.elementAt(counter),
            )
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items:  const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.doc_text_fill), label: 'Invoices'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Clients'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Services'),
            BottomNavigationBarItem(icon: Icon(Icons.arrow_circle_right), label: 'Unimplemented'),
          ],
          currentIndex: counter,
          selectedItemColor: Colors.amber[800],
          onTap: onItemTapped,
        ),
      );
    }
  }