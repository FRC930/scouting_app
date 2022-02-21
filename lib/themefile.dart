import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const mainColor = Color(0xFF1D57A5);
const accent1 = Color(0xFF4698CA);
const accent2 = Color(0xFFFBDB65);

ThemeData mainThemeData = ThemeData(
  scaffoldBackgroundColor: const Color(0xFF222222),
  appBarTheme: const AppBarTheme(
    backgroundColor: mainColor,
    iconTheme: IconThemeData(size: 30),
  ),
  colorScheme: ColorScheme.dark(
    primary: mainColor,
    error: Colors.red.shade200,
    outline: Colors.white,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: mainColor,
    textTheme: ButtonTextTheme.accent,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: mainColor,
    foregroundColor: Colors.white,
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: const Color(0xFF222222),
    filled: true,
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white38, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red.shade200, width: 2.0),
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: accent1, width: 3.0),
    ),
    disabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.white38, width: 2.0),
    ),
  ),
  textTheme: TextTheme(
    headlineMedium: GoogleFonts.montserrat(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: const Color(0xFFFFFFFF),
    ),
    displayMedium: GoogleFonts.openSans(
      color: accent2,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: GoogleFonts.openSans(
      color: const Color(0xFFFFFFFF),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Colors.white,
    size: 40,
  ),
  unselectedWidgetColor: accent1,
  
);
