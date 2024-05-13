import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/providers/auth_provider.dart';

import 'home_screen.dart';
import 'login_screen.dart';

class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) return const HomeScreen();
          return const LoginScreen();
      },
      loading: () => const SplashScreen(),
      error: (e, trace) => const LoginScreen()
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

