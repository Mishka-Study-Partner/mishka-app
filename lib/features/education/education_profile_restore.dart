import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mishka_app/features/Auth/data/models/user_model.dart';
import 'package:mishka_app/features/Auth/view/bloc/auth_bloc.dart';
import 'package:mishka_app/features/education/education_flow_config.dart';

/// Resolves the user whose education should pre-fill the flow.
UserModel? educationUser(BuildContext context, EducationFlowConfig config) {
  if (config.initialUser != null) return config.initialUser;
  final state = context.read<AuthBloc>().state;
  if (state is AuthSuccess) return state.user;
  return null;
}
