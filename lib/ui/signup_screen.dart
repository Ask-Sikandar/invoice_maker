import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../firebase_options.dart';
import 'package:invoice_maker/ui/vm/signup_controller.dart';
import 'package:invoice_maker/ui/vm/signup_state.dart';

import 'login_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget{
  const SignUpScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ref.listen<SignUpState>(signUpControllerProvider, ((previous, state) {
      if (state is SignUpStateError) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error),
        ));
      }
    }));
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 70),
            children: <Widget>[
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Invoice Builder',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                        fontSize: 30),
                  )),
              Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(10),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(fontSize: 20),
                  )),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email Address',
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              Container(
                  height: 50,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: ElevatedButton(
                    child: const Text('Sign up'),
                    onPressed: () {
                      ref
                          .read(signUpControllerProvider.notifier)
                          .signup(emailController.text, passwordController.text);
                    },
                  )),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('Already have account?'),
                  TextButton(
                    child: const Text(
                      'login',
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                  )
                ],
              ),
            ],
          )),
    );
  }
}
