import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_bloc.dart';
import 'package:po_pal/services/auth/bloc/auth_events.dart';
import 'package:po_pal/services/auth/bloc/auth_states.dart';
import 'package:po_pal/services/auth/firebase_auth_provider.dart';
import 'package:po_pal/services/preferences/bloc/pref_bloc.dart';
import 'package:po_pal/services/preferences/bloc/pref_events.dart';
import 'package:po_pal/theme/light_theme.dart';
import 'package:po_pal/utilities/loading/loading_screen.dart';
import 'package:po_pal/views/authentication/forgot_password_view.dart';
import 'package:po_pal/views/authentication/login_view.dart';
import 'package:po_pal/views/navigation_view.dart';
import 'package:po_pal/views/authentication/register_view.dart';
import 'package:po_pal/views/authentication/verify_email_view.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:po_pal/views/offline_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc(FirebaseAuthProvider())),
        BlocProvider<PrefBloc>(
          create: (_) => PrefBloc()..add(const PrefEventLoadPreferences()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PO Pal',
        theme: lightTheme(),
        home: const HomePage(),
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
          LoadingScreen().show(context: context);
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return StreamBuilder<ConnectivityResult>(
            stream: Connectivity().onConnectivityChanged.map(
              (results) =>
                  results.isNotEmpty ? results.first : ConnectivityResult.none,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active &&
                  snapshot.hasData) {
                final hasConnection = snapshot.data != ConnectivityResult.none;
                return hasConnection
                    ? NavigationView(userId: state.userId)
                    : const OfflineView();
              }
              return const Center(child: CircularProgressIndicator());
            },
          );
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else {
          return Scaffold(
            body: Center(
              child: Image.asset(
                'assets/po_pal_icon.png',
                width: 150,
                height: 150,
                color: Color.fromARGB(255, 234, 232, 232),
              ),
            ),
          );
        }
      },
    );
  }
}
