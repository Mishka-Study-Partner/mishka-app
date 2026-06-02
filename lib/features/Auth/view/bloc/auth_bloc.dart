import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/token_storage.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/settings/data/models/user_preferences_model.dart';

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
      await _emitAuthenticatedUser(emit, auth.user);
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
      await _emitAuthenticatedUser(emit, auth.user);
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
      final me = await _remote.getCurrentUser().timeout(
        const Duration(seconds: 10),
      );
      await _cacheUser(me.user);
      emit(AuthSuccess(me.user, preference: me.preference));
    } on ApiException catch (e) {
      if (previousUser != null) return;
      if (_isTokenInvalid(e)) {
        await TokenStorage.clearToken();
        await AppPreferences.setCachedUserJson(null);
        emit(AuthError(e.message, e.error));
        return;
      }
      final cached = _loadCachedUser();
      if (_isRecoverableMeFailure(e) && cached != null) {
        emit(AuthSuccess(cached));
        return;
      }
      emit(AuthError(e.message, e.error));
    } on FormatException catch (e) {
      if (previousUser != null) return;
      emit(AuthError(e.message, 'INVALID_RESPONSE'));
    } catch (_) {
      if (previousUser != null) return;
      emit(const AuthInitial());
    }
  }

  bool _isTokenInvalid(ApiException e) {
    return e.statusCode == 401 ||
        e.error == 'AUTH_INVALID_TOKEN' ||
        e.error == 'AUTH_MISSING_TOKEN';
  }

  void _onReplaceUser(AuthReplaceUser event, Emitter<AuthState> emit) {
    final preference = switch (state) {
      AuthSuccess(:final preference) => preference,
      _ => null,
    };
    emit(AuthSuccess(event.user, preference: preference));
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _remote.logout();
    await AppPreferences.setCachedUserJson(null);
    emit(const AuthInitial());
  }

  Future<void> _emitAuthenticatedUser(
    Emitter<AuthState> emit,
    UserModel fallbackUser,
  ) async {
    try {
      final me = await _remote.getCurrentUser();
      await _cacheUser(me.user);
      emit(AuthSuccess(me.user, preference: me.preference));
    } on ApiException catch (e) {
      if (_isRecoverableMeFailure(e)) {
        await _cacheUser(fallbackUser);
        emit(AuthSuccess(fallbackUser));
        return;
      }
      rethrow;
    }
  }

  Future<void> _cacheUser(UserModel user) async {
    await AppPreferences.setCachedUserJson(jsonEncode(user.toJson()));
  }

  UserModel? _loadCachedUser() {
    final raw = AppPreferences.cachedUserJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  bool _isRecoverableMeFailure(ApiException e) {
    return e.statusCode != null && e.statusCode! >= 500;
  }
}
