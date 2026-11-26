import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/festive_background.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final auth = AuthService();

  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkSession();
  }

  Future<void> checkSession() async {
    final loggedIn = await auth.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
      return;
    }

    setState(() {
      loading = false;
    });
  }

  void openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF050706),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.lime,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050706),
      body: FestiveBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 26,
              vertical: 20,
            ),
            child: Column(
              children: [
                const Spacer(),

                // =========================
                // DECORACIÓN NAVIDEÑA
                // =========================

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      '🎄',
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '❄️',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '🎅',
                      style: TextStyle(fontSize: 30),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '❄️',
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 12),
                    Text(
                      '🎄',
                      style: TextStyle(fontSize: 25),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // =========================
                // LOGO
                // =========================

                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: AppTheme.lime,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lime.withValues(
                          alpha: 0.35,
                        ),
                        blurRadius: 28,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.fitness_center,
                        color: Colors.black,
                        size: 48,
                      ),
                      Positioned(
                        right: 8,
                        top: 6,
                        child: Text(
                          '🎅',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // =========================
                // TÍTULO
                // =========================

                const Text(
                  'PULSE FIT',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  '🎄 EDICIÓN NAVIDEÑA 🎄',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.lime,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'TU MOVIMIENTO.\nTUS PROPIAS MARCAS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'Entrena con datos reales de tu dispositivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.muted,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 25),

                // =========================
                // MENSAJE NAVIDEÑO
                // =========================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.07,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppTheme.lime.withValues(
                        alpha: 0.25,
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '🎁',
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Estas fiestas, el mejor regalo es seguir moviéndote.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // =========================
                // INICIAR SESIÓN
                // =========================

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: FilledButton.icon(
                    onPressed: openLogin,
                    icon: const Icon(
                      Icons.login_rounded,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.lime,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 8,
                      shadowColor: AppTheme.lime.withValues(
                        alpha: 0.35,
                      ),
                    ),
                    label: const Text(
                      'INICIAR SESIÓN',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // =========================
                // CREAR CUENTA
                // =========================

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton.icon(
                    onPressed: openRegister,
                    icon: const Icon(
                      Icons.person_add_alt_1,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: AppTheme.lime.withValues(
                          alpha: 0.75,
                        ),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    label: const Text(
                      'CREAR CUENTA',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // =========================
                // HUELLA
                // =========================

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.fingerprint,
                      color: AppTheme.lime,
                      size: 18,
                    ),
                    SizedBox(width: 7),
                    Flexible(
                      child: Text(
                        'Después podrás acceder rápidamente con tu huella.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.muted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const Text(
                  '❄️  FELICES FIESTAS  ❄️',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}