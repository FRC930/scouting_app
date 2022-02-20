import 'package:flutter/material.dart';

Theme createMainTheme(Widget childItem) {
  return Theme(
    data: ThemeData(
      colorSchemeSeed: const Color(0xFF1E22AA),
      backgroundColor: const Color(0xFF222222),
    ),
    child: childItem,
  );
}

ThemeData mainThemeData = ThemeData(
  colorSchemeSeed: const Color(0xFF1E22AA),
  backgroundColor: const Color(0xFF222222),
  buttonTheme: const ButtonThemeData(
    buttonColor: Color(0xFF1D57A5),
  ),
);
