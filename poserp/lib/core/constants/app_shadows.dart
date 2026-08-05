import 'package:flutter/material.dart';

class AppShadows {
  static const List<BoxShadow> cardLight = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.06),
      blurRadius: 36,
      offset: Offset(0, 14),
    ),
  ];

  static const List<BoxShadow> cardDark = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.22),
      blurRadius: 48,
      offset: Offset(0, 18),
    ),
  ];

  static const List<BoxShadow> dropdown = [
    BoxShadow(
      color: Color.fromRGBO(15, 23, 42, 0.12),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];
}
