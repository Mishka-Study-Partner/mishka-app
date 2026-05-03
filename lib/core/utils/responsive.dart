import 'package:flutter/material.dart';

class R {
  static double w(BuildContext c, double v) =>
      MediaQuery.of(c).size.width * (v / 375);

  static double h(BuildContext c, double v) =>
      MediaQuery.of(c).size.height * (v / 812);
}
