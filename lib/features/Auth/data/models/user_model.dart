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
    this.educationStatus,
    this.educationOtherDetail,
    this.schoolTrack,
    this.schoolGrade,
    this.universityYear,
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
  final String? educationStatus;
  final String? educationOtherDetail;
  final String? schoolTrack;
  final int? schoolGrade;
  final int? universityYear;
  final String? createdAt;
  final String? updatedAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      fullName: json['fullName'] as String?,
      username: json['username'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      countryCode: json['countryCode'] as String?,
      role: json['role'] as String?,
      isVerified: json['isVerified'] as bool?,
      profileImageUrl: json['profileImageUrl'] as String?,
      gender: json['gender'] as String?,
      educationStatus: json['educationStatus'] as String?,
      educationOtherDetail: json['educationOtherDetail'] as String?,
      schoolTrack: json['schoolTrack'] as String?,
      schoolGrade: _parseIntOrNull(json['schoolGrade']),
      universityYear: _parseIntOrNull(json['universityYear']),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
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
        'educationStatus': educationStatus,
        'educationOtherDetail': educationOtherDetail,
        'schoolTrack': schoolTrack,
        'schoolGrade': schoolGrade,
        'universityYear': universityYear,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
