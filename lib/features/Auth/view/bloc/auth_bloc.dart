import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/token_storage.dart';

import '../../data/data_sources/auth_remote_data_source.dart';
import '../../data/models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._remote) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterRequested>(_onRegister);
    on<AuthLoadUserRequested>(_onLoadUser);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthReplaceUser>(_onReplaceUser);
  }

  final AuthRemoteDataSource _remote;

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final auth = await _remote.login(
        email: event.email,
        phoneNumber: event.phoneNumber,
        countryCode: event.countryCode,
        password: event.password,
        rememberMe: event.rememberMe,
      );
      emit(AuthSuccess(auth.user));
    } on ApiException catch (e) {
      emit(AuthError(e.message, e.error));
    } on FormatException catch (e) {
      emit(AuthError(e.message, 'INVALID_RESPONSE'));
    }
  }

  Future<void> _onRegister(AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final auth = await _remote.register(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        agreeTerms: event.agreeTerms,
        phoneNumber: event.phoneNumber,
        countryCode: event.countryCode,
        educationStatus: event.educationStatus,
        signupOtp: event.signupOtp,
      );
      emit(AuthSuccess(auth.user));
    } on ApiException catch (e) {
      emit(AuthError(e.message, e.error));
    } on FormatException catch (e) {
      emit(AuthError(e.message, 'INVALID_RESPONSE'));
    }
  }

  Future<void> _onLoadUser(AuthLoadUserRequested event, Emitter<AuthState> emit) async {
    final token = TokenStorage.token;
    if (token == null || token.isEmpty) {
      emit(const AuthInitial());
      return;
    }
    final previousUser = switch (state) {
      AuthSuccess(:final user) => user,
      _ => null,
    };
    if (previousUser == null) {
      emit(const AuthLoading());
    }
    try {
      final user = await _remote.getCurrentUser();
      emit(AuthSuccess(user));
    } on ApiException catch (e) {
      if (previousUser != null) {
        return;
      }
      emit(AuthError(e.message, e.error));
    } on FormatException catch (e) {
      if (previousUser != null) {
        return;
      }
      emit(AuthError(e.message, 'INVALID_RESPONSE'));
    }
  }

  void _onReplaceUser(AuthReplaceUser event, Emitter<AuthState> emit) {
    emit(AuthSuccess(event.user));
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _remote.logout();
    emit(const AuthInitial());
  }
}
