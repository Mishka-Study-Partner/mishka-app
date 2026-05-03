part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.agreeTerms,
    this.phoneNumber,
    this.countryCode,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final bool agreeTerms;
  final String? phoneNumber;
  final String? countryCode;

  @override
  List<Object?> get props =>
      [firstName, lastName, email, password, agreeTerms, phoneNumber, countryCode];
}

class AuthLoadUserRequested extends AuthEvent {
  const AuthLoadUserRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
