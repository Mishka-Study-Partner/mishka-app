part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.user, {this.preference});

  final UserModel user;

  /// From `GET /auth/me` `preference` when present; null = do not change app UI prefs.
  final UserPreferencesModel? preference;

  @override
  List<Object?> get props => [user, preference];
}

class AuthError extends AuthState {
  const AuthError(this.message, this.errorCode);

  /// Localized message from API (`message` field — use for UI).
  final String message;

  /// Stable code from API (`error` field — use for logic).
  final String? errorCode;

  @override
  List<Object?> get props => [message, errorCode];
}
