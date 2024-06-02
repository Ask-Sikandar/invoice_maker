// lib/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../repository/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final fireBaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStateProvider = StreamProvider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
});

class SignInStateNotifier extends StateNotifier<bool> {
  SignInStateNotifier(this.ref) : super(false);

  final Ref ref;

  Future<User?> signInWithGoogle() async {
    try {
      state = true;
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signInWithGoogle();
      return user;
    } catch (e) {
      throw e;
    } finally {
      state = false;
    }
  }

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      state = true;
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signInWithEmailAndPassword(email, password);
      return user;
    } catch (e) {
      throw e;
    } finally {
      state = false;
    }
  }

  Future<User?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      state = true;
      final authRepository = ref.read(authRepositoryProvider);
      final user = await authRepository.signUpWithEmailAndPassword(email, password);
      return user;
    } catch (e) {
      throw e;
    } finally {
      state = false;
    }
  }

  Future<void> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.signOut();
  }
}

final signInStateProvider = StateNotifierProvider<SignInStateNotifier, bool>((ref) {
  return SignInStateNotifier(ref);
});
