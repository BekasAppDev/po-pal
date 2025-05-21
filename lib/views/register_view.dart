import 'package:po_pal/services/auth/auth_exceptions.dart';
import 'package:po_pal/services/auth/bloc/auth_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_events.dart';
import 'package:po_pal/services/auth/bloc/auth_states.dart';
import 'package:po_pal/utilities/dialogs/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(
              context,
              'Password must consist of atleast 6 characters',
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, 'Email already in use');
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, 'Invalid email adress');
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(context, 'Authentication Error');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Sign up'), centerTitle: true),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/po_pal_icon.png',
                  height: 100,
                  color: Colors.black,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _email,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: true,
                  decoration: const InputDecoration(hintText: 'Enter email'),
                ),
                TextField(
                  controller: _password,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(hintText: 'Enter password'),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      },
                      child: const Text(
                        'Already have an account?',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationThickness: 3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    final email = _email.text;
                    final password = _password.text;
                    context.read<AuthBloc>().add(
                      AuthEventRegister(email, password),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
