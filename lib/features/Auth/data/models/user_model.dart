/// Mirrors backend `user` JSON (Prisma camelCase).
class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.fullName,
    this.username,
    this.phoneNumber,
    this.countryCode,
    this.role,
    this.isVerified,
    this.profileImageUrl,
    this.gender,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? fullName;
  final String? username;
  final String? phoneNumber;
  final String? countryCode;
  final String? role;
  final bool? isVerified;
  final String? profileImageUrl;
  final String? gender;
  final String? createdAt;
  final String? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      username: json['username'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      countryCode: json['countryCode'] as String?,
      role: json['role'] as String?,
      isVerified: json['isVerified'] as bool?,
      profileImageUrl: json['profileImageUrl'] as String?,
      gender: json['gender'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'fullName': fullName,
        'username': username,
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
        'role': role,
        'isVerified': isVerified,
        'profileImageUrl': profileImageUrl,
        'gender': gender,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
