part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({
    this.email,
    this.phoneNumber,
    this.countryCode,
    required this.password,
    this.rememberMe = false,
  });

  final String? email;
  final String? phoneNumber;
  final String? countryCode;
  final String password;
  final bool rememberMe;

  @override
  List<Object?> get props => [email, phoneNumber, countryCode, password, rememberMe];
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
    this.educationStatus,
    this.signupOtp,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final bool agreeTerms;
  final String? phoneNumber;
  final String? countryCode;
  final String? educationStatus;
  final String? signupOtp;

  @override
  List<Object?> get props =>
      [
        firstName,
        lastName,
        email,
        password,
        agreeTerms,
        phoneNumber,
        countryCode,
        educationStatus,
        signupOtp,
      ];
}

class AuthLoadUserRequested extends AuthEvent {
  const AuthLoadUserRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Replace session user (e.g. after profile pull-to-refresh) without going through [AuthLoadUserRequested].
class AuthReplaceUser extends AuthEvent {
  const AuthReplaceUser(this.user);

  final UserModel user;

  @override
  List<Object?> get props => [user];
}
