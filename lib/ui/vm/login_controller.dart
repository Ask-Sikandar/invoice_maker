import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invoice_maker/ui/vm/login_state.dart';


class LoginController extends StateNotifier<LoginState> {
  LoginController(this.ref) : super(const LoginStateInitial());

  final Ref ref;

  void signOut() async {
    await ref.read(authRepositoryProvider).signOut();
  }

  void login(String emailAddress, String password) async {
    try {
      await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
          emailAddress, password);
      state = const LoginStateSuccess();
    } catch (e) {
      state = LoginStateError(e.toString());
      print(e.toString());
    }
  }
}
  final loginControllerProvider = StateNotifierProvider<
      LoginController,
      LoginState>((ref) {
    return LoginController(ref);
  });