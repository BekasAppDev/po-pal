import 'package:po_pal/services/auth/auth_provider.dart';
import 'package:po_pal/services/auth/bloc/auth_events.dart';
import 'package:po_pal/services/auth/bloc/auth_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
    : super(const AuthStateUninitialized(isLoading: true)) {
    //send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });
    //navigating to register view
    on<AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(exception: null, isLoading: false));
    });
    //register
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(AuthStateNeedsVerification(isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateRegistering(exception: e, isLoading: false));
      }
    });
    //initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });
    //log in
    on<AuthEventLogIn>((event, emit) async {
      emit(AuthStateLoggedOut(exception: null, isLoading: true));
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.logIn(email: email, password: password);
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
        if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification(isLoading: false));
        } else {
          emit(AuthStateLoggedIn(user: user, isLoading: false));
        }
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    //Log out
    on<AuthEventLogOut>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
    //forgot password
    on<AuthEventForgotPassword>((event, emit) async {
      emit(
        AuthStateForgotPassword(
          isLoading: false,
          exception: null,
          hasSentEmail: false,
        ),
      );
      final email = event.email;
      if (email == null) {
        return;
      }
      emit(
        AuthStateForgotPassword(
          isLoading: true,
          exception: null,
          hasSentEmail: false,
        ),
      );
      bool didSendEmail;
      Exception? exception;
      try {
        await provider.sendPasswordReset(toEmail: email);
        didSendEmail = true;
        exception = null;
      } on Exception catch (e) {
        didSendEmail = false;
        exception = e;
      }
      emit(
        AuthStateForgotPassword(
          isLoading: false,
          exception: exception,
          hasSentEmail: didSendEmail,
        ),
      );
    });
    //checking verification progress
    on<AuthEventCheckEmailVerification>((event, emit) async {
      await provider.reloadUser();
      final user = provider.currentUser;
      if (user != null && user.isEmailVerified) {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    });
    //deleting user
    on<AuthEventDeleteUser>((event, emit) async {
      try {
        await provider.deleteUser(password: event.password);
        emit(AuthStateLoggedOut(exception: null, isLoading: false));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e, isLoading: false));
      }
    });
  }
}
