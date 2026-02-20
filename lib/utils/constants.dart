import 'package:flutter/material.dart';

class AppConstants {
  static const List<Color> noteColors = [
    Color(0xFFFFFF00),
    Color(0xFF90EE90),
    Color(0xFF87CEEB),
    Color(0xFFFFB6C1),
    Color(0xFFDDA0DD),
    Color(0xFFF0E68C),
    Color(0xFFFFA07A),
    Color(0xFF98FB98),
    Color(0xFFFFC0CB),
    Color(0xFFE6E6FA),
  ];

  static const double defaultNoteWidth = 250.0;
  static const double defaultNoteHeight = 300.0;
  static const double minNoteWidth = 200.0;
  static const double minNoteHeight = 150.0;
  static const double maxNoteWidth = 500.0;
  static const double maxNoteHeight = 600.0;

  static const EdgeInsets notePadding = EdgeInsets.all(12.0);
  static const double borderRadius = 8.0;
  
  static const Color darkTextColor = Color(0xFF333333);
  static const Color lightTextColor = Color(0xFFFFFFFF);
}