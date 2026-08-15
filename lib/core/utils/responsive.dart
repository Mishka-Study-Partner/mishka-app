import 'package:flutter/material.dart';

import 'package:mishka_app/core/layout/app_scale.dart';

/// Legacy helpers — prefer [AppScale] or `.rw` / `.rh` extensions.
class R {
  static double w(BuildContext c, double v) => AppScale.w(v);

  static double h(BuildContext c, double v) => AppScale.h(v);
}
