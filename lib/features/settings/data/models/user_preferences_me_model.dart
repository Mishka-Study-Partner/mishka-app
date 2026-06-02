import 'report_email_preferences_model.dart';
import 'user_preferences_model.dart';

class UserPreferencesMeModel {
  const UserPreferencesMeModel({
    this.core,
    this.reportEmail = const ReportEmailPreferencesModel(),
  });

  final UserPreferencesModel? core;
  final ReportEmailPreferencesModel reportEmail;

  factory UserPreferencesMeModel.fromJson(Map<String, dynamic> json) {
    final reportRaw = json['reportEmail'];
    return UserPreferencesMeModel(
      core: UserPreferencesModel.tryParseEnvelopeData(json),
      reportEmail: reportRaw is Map
          ? ReportEmailPreferencesModel.fromJson(
              Map<String, dynamic>.from(reportRaw),
            )
          : ReportEmailPreferencesModel.fromJson(json),
    );
  }
}
