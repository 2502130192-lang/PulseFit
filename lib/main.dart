import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PulseFitApp());
}

class PulseFitApp extends StatelessWidget {
  const PulseFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PULSE FIT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const WelcomeScreen(),
    );
  }
}