// @author Rayane Rousseau
import 'package:flutter/material.dart';

const Color kPrimary = Color(0xFF2C3E87);
const Color kAccent = Color(0xFF00C9A7);
const Color kSurface = Color(0xFFF0F4FF);
const Color kOnPrimary = Color(0xFFFFFFFF);
const Color kDarkSurface = Color(0xFF0D1117);
const Color kDarkCard = Color(0xFF161B22);
const Color kDarkText = Color(0xFFE6EDF3);

ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: kSurface,
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        backgroundColor: kPrimary,
        foregroundColor: kOnPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary,
          foregroundColor: kOnPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: kAccent.withOpacity(0.15),
        labelStyle: const TextStyle(color: kAccent, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );

ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: kPrimary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: kDarkSurface,
      fontFamily: 'Poppins',
      appBarTheme: const AppBarTheme(
        backgroundColor: kDarkCard,
        foregroundColor: kDarkText,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      cardTheme: CardThemeData(
        color: kDarkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
