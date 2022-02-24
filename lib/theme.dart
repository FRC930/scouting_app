import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const appMainColor = Color(0xFF1D57A5);
const appAccent1 = Color(0xFF4698CA);
const appAccent2 = Color(0xFFFBDB65);
const appBackgroundColor = Color(0xFF222222);
const appForegroundColor = Color(0xFFEEEEEE);

final ThemeData appThemeData = ThemeData(
  scaffoldBackgroundColor: appBackgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: appMainColor,
    iconTheme: IconThemeData(
      size: 30,
      color: appForegroundColor,
    ),
  ),
  colorScheme: ColorScheme.dark(
    primary: appMainColor,
    error: Colors.red.shade200,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: appMainColor,
    textTheme: ButtonTextTheme.accent,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: appMainColor,
    foregroundColor: appForegroundColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: appBackgroundColor,
    filled: true,
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white38, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade200, width: 2.0),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: appAccent1, width: 3.0),
    ),
    disabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white38, width: 2.0),
    ),
  ),
  textTheme: TextTheme(
    headlineMedium: GoogleFonts.montserrat(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      color: appForegroundColor,
    ),
    displayMedium: GoogleFonts.openSans(
      color: appAccent2,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: GoogleFonts.openSans(
      color: appForegroundColor,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),
  iconTheme: const IconThemeData(
    color: appForegroundColor,
    size: 40,
  ),
  unselectedWidgetColor: appAccent1,
);
