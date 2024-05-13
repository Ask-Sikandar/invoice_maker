import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_maker/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:invoice_maker/ui/vm/login_state.dart';
import 'package:invoice_maker/ui/vm/signup_state.dart';


class SignUpController extends StateNotifier<SignUpState> {
  SignUpController(this.ref) : super(const SignUpStateInitial());

  final Ref ref;

  void signup(String emailAddress, String password) async {
    try {
      await ref.read(authRepositoryProvider).signUpWithEmailAndPassword(
          emailAddress, password);
      state = const SignUpStateSuccess();
    } catch (e) {
      state = SignUpStateError(e.toString());
    }
  }
}
final signUpControllerProvider = StateNotifierProvider<
    SignUpController,
    SignUpState>((ref) {
  return SignUpController(ref);
});