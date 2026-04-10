import 'package:flutter/material.dart';
import 'constants.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppConstants.primaryColor,
    scaffoldBackgroundColor: AppConstants.backgroundColor,
    colorScheme: ColorScheme.light(
      primary: AppConstants.primaryColor,
      onPrimary: Colors.white,
      secondary: AppConstants.accentYellow,
      onSecondary: Colors.black87,
      surface: AppConstants.cardWhite,
      onSurface: Colors.black87,
      error: AppConstants.accentOrange,
      outline: const Color(0xFFE2E8F0),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppConstants.cardWhite,
      foregroundColor: Colors.black87,
      titleTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppConstants.cardWhite,
      selectedItemColor: AppConstants.primaryColor,
      unselectedItemColor: AppConstants.secondaryColor,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppConstants.cardWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppConstants.accentYellow,
        foregroundColor: Colors.black87,
        minimumSize: Size(double.infinity, AppConstants.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        minimumSize: Size(double.infinity, AppConstants.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F2F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  );
}
