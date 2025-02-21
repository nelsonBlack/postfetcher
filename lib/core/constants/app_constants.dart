import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/responsive_layout.dart';

class AppConstants {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const int postsPerPage = 10;

  static final TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
      fontSize: 57,
      fontWeight: FontWeight.w400,
    ),
    displayMedium: GoogleFonts.poppins(
      fontSize: 45,
      fontWeight: FontWeight.w400,
    ),
    displaySmall: GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.w400,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 28,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w400,
    ),
    titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
    titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
    titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
    labelSmall: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500),
  );

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
    textTheme: textTheme,
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
    textTheme: textTheme,
  );

  static ThemeData getTheme(BuildContext context, ThemeMode themeMode) {
    final isDesktop = ResponsiveLayout.isDesktop(context);
    return (themeMode == ThemeMode.dark ? darkTheme : lightTheme).copyWith(
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: isDesktop ? Colors.blueGrey : null,
        displayColor: isDesktop ? Colors.indigo : null,
      ),
    );
  }
}
