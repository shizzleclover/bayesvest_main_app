// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

class AppColors{
  static bool _isdarkMode = false;
  static void setDarkmode(bool isDark) {
    _isdarkMode = isDark;
  }

  static const PrimaryBlue = Color(0xFF0066FF);
  static const PrimaryBlueDark = Color(0xFF0052CC);
  static const PrimaryBlueLight = Color(0xFF4D8FFF);

  static const SecondaryCol = Color(0xFF6B7280);
  static const SecondaryColDark = Color(0xFF555B66);
  static const SecondaryColLight = Color(0xFF8D94A3);

  static const TetiaryCol = Color(0xFF0D111F);
  static const TetiaryColDark = Color(0xFF0A0D16);
  static const TetiaryColLight = Color(0xFF141926);



  static const NeutralCol = Color(0xFF111827);
  static const NeutralColDark = Color(0xFF0E131F);
  static const NeutralColLight = Color(0xFF1F2937);
  
}