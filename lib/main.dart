import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_events.dart';
import 'package:po_pal/services/auth/bloc/auth_states.dart';
import 'package:po_pal/services/auth/firebase_auth_provider.dart';
import 'package:po_pal/theme/light_theme.dart';
import 'package:po_pal/utilities/loading/loading_screen.dart';
import 'package:po_pal/views/forgot_password_view.dart';
import 'package:po_pal/views/login_view.dart';
import 'package:po_pal/views/register_view.dart';
import 'package:po_pal/views/tracking_view.dart';
import 'package:po_pal/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BlocProvider<AuthBloc>.value(
      value: AuthBloc(FirebaseAuthProvider()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PO Pal',
        theme: lightTheme(),
        home: const HomePage(),
        routes: {},
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (BuildContext context, AuthState state) {
        if (state.isLoading) {
          LoadingScreen().show(context: context, text: state.loadingText);
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const TrackingView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else {
          return const Scaffold(body: Text('if i end up here i f***'));
        }
      },
    );
  }
}
