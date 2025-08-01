import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthEvent {
  final String email;
  final String password;

  const AuthEventLogIn(this.email, this.password);
}

class AuthEventLogOut extends AuthEvent {
  const AuthEventLogOut();
}

class AuthEventSendEmailVerification extends AuthEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}

class AuthEventRegister extends AuthEvent {
  final String email;
  final String password;

  const AuthEventRegister(this.email, this.password);
}

class AuthEventForgotPassword extends AuthEvent {
  final String? email;
  const AuthEventForgotPassword({required this.email});
}

class AuthEventDeleteUser extends AuthEvent {
  final String password;
  const AuthEventDeleteUser({required this.password});
}

class AuthEventCheckEmailVerification extends AuthEvent {
  const AuthEventCheckEmailVerification();
}
