import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/premium_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.instance.initialize();

  // Initialize in-app purchases
  await PremiumService.instance.initialize();

  runApp(const ThreeQuestionJournal());
}

class ThreeQuestionJournal extends StatelessWidget {
  const ThreeQuestionJournal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3 Question Journal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Calm blue/purple color scheme
        primaryColor: const Color(0xFF6B5B95), // Soft purple
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B5B95),
          primary: const Color(0xFF6B5B95),
          secondary: const Color(0xFF7B8CDE), // Calm blue
          surface: const Color(0xFFF5F7FA),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),

        // Typography using Google Fonts
        textTheme: GoogleFonts.nunitoTextTheme().copyWith(
          headlineLarge: GoogleFonts.nunito(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2D3748),
          ),
          headlineMedium: GoogleFonts.nunito(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2D3748),
          ),
          bodyLarge: GoogleFonts.nunito(
            fontSize: 16,
            color: const Color(0xFF4A5568),
          ),
          bodyMedium: GoogleFonts.nunito(
            fontSize: 14,
            color: const Color(0xFF4A5568),
          ),
        ),

        // App bar theme
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF6B5B95),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFF6B5B95), width: 2),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),

        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6B5B95),
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.nunito(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Card theme
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),

        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
