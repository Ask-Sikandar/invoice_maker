import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/repository/auth_repository.dart';
import 'package:invoice_maker/ui/vm/login_controller.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: (){
                ref.read(loginControllerProvider.notifier).signOut();
              }, icon: const Icon(Icons.logout)),
        ],
      ),
      body: const Center(child: Text('Hello'),),
    );
  }
}
