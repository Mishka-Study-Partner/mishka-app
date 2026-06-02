import 'package:mishka_app/features/Auth/data/models/user_model.dart';

/// When [isProfileEdit] is true, completing the flow PATCHes profile and pops
/// instead of navigating to [MainScreen].
class EducationFlowConfig {
  const EducationFlowConfig({
    this.isProfileEdit = false,
    this.initialUser,
  });

  final bool isProfileEdit;

  /// Current profile user when editing from profile (pre-selects choices).
  final UserModel? initialUser;
}
