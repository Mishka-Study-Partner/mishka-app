import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';

import '../models/student_subject_model.dart';

class StudentSubjectsRemoteDataSource {
  StudentSubjectsRemoteDataSource(this._api);

  final ApiService _api;

  Future<List<StudentSubjectModel>> listSubjects() async {
    final env = await _api.get<List<StudentSubjectModel>>(
      ApiEndpoints.studentSubjects,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => StudentSubjectModel.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<StudentSubjectModel> createSubject({
    required String name,
    required String color,
  }) async {
    final env = await _api.post<StudentSubjectModel>(
      ApiEndpoints.studentSubjects,
      data: {'name': name.trim(), 'color': color},
      dataFromJson: (raw) {
        if (raw is Map) {
          return StudentSubjectModel.fromJson(Map<String, dynamic>.from(raw));
        }
        throw const FormatException('Invalid student subject response');
      },
    );
    return env.data!;
  }

  Future<StudentSubjectModel> updateSubject(StudentSubjectModel subject) async {
    final env = await _api.patch<StudentSubjectModel>(
      ApiEndpoints.studentSubjectById(subject.id),
      data: subject.toUpdateJson(),
      dataFromJson: (raw) {
        if (raw is Map) {
          return StudentSubjectModel.fromJson(Map<String, dynamic>.from(raw));
        }
        throw const FormatException('Invalid student subject response');
      },
    );
    return env.data!;
  }

  Future<void> deleteSubject(String id) async {
    await _api.delete<void>(ApiEndpoints.studentSubjectById(id));
  }
}
