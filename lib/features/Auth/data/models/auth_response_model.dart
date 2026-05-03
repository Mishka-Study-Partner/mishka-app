import 'user_model.dart';

/// `data` object from `POST /auth/login` and `POST /auth/register`.
class AuthResponseModel {
  const AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    this.expiresIn,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final String? expiresIn;
  final UserModel user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final token = json['accessToken'] as String? ?? json['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('Missing accessToken in auth response');
    }
    return AuthResponseModel(
      accessToken: token,
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresIn: json['expiresIn'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
