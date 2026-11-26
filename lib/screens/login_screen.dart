import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import '../widgets/festive_background.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final auth = AuthService();
  final biometric = BiometricService();

  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // =========================
  // INICIAR SESIÓN
  // =========================

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      message('Ingresa tu correo y contraseña.');
      return;
    }

    setState(() {
      loading = true;
    });

    final ok = await auth.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (ok) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
            (_) => false,
      );
    } else {
      message('Correo o contraseña incorrectos.');
    }
  }

  // =========================
  // INICIAR CON HUELLA
  // =========================

  Future<void> loginWithBiometric() async {
    final registered = await auth.hasRegisteredAccount();

    if (!mounted) return;

    if (!registered) {
      message('Primero debes crear una cuenta.');
      return;
    }

    final ok = await biometric.authenticate();

    if (!mounted) return;

    if (!ok) {
      message('No se pudo validar la huella.');
      return;
    }

    await auth.biometricLogin();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
          (_) => false,
    );
  }

  // =========================
  // MENSAJES
  // =========================

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // =========================
  // PANTALLA
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050706),
      body: FestiveBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            children: [
              // =========================
              // DECORACIÓN
              // =========================

              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                    style: TextStyle(fontSize: 28),
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

              const SizedBox(height: 22),

              // =========================
              // LOGO
              // =========================

              Center(
                child: Container(
                  width: 90,
                  height: 90,
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
                        Icons.lock_open_rounded,
                        color: Colors.black,
                        size: 45,
                      ),
                      Positioned(
                        right: 7,
                        top: 5,
                        child: Text(
                          '🎅',
                          style: TextStyle(
                            fontSize: 23,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // TÍTULO
              // =========================

              const Text(
                'BIENVENIDO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                '🎄 PULSE FIT · EDICIÓN NAVIDEÑA 🎄',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.lime,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 9),

              const Text(
                'Ingresa a tu cuenta y continúa con tu entrenamiento.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.muted,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 30),

              // =========================
              // CORREO
              // =========================

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  hintText: 'correo@ejemplo.com',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: AppTheme.lime,
                  ),
                  labelStyle: const TextStyle(
                    color: AppTheme.muted,
                  ),
                  hintStyle: const TextStyle(
                    color: Colors.white30,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(
                    alpha: 0.06,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(
                        alpha: 0.10,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: AppTheme.lime,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =========================
              // CONTRASEÑA
              // =========================

              TextField(
                controller: passwordController,
                obscureText: hidePassword,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppTheme.lime,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    icon: Icon(
                      hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                  ),
                  labelStyle: const TextStyle(
                    color: AppTheme.muted,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(
                    alpha: 0.06,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(
                        alpha: 0.10,
                      ),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: AppTheme.lime,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // =========================
              // INICIAR SESIÓN
              // =========================

              SizedBox(
                height: 58,
                child: FilledButton.icon(
                  onPressed: loading ? null : login,
                  icon: Icon(
                    loading
                        ? Icons.hourglass_top
                        : Icons.login_rounded,
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
                  label: Text(
                    loading
                        ? 'VALIDANDO...'
                        : 'INICIAR SESIÓN',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 13),

              // =========================
              // HUELLA
              // =========================

              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: loginWithBiometric,
                  icon: const Icon(
                    Icons.fingerprint,
                    size: 27,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: AppTheme.lime.withValues(
                        alpha: 0.70,
                      ),
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  label: const Text(
                    'ENTRAR CON HUELLA',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // =========================
              // SEPARADOR
              // =========================

              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      'O',
                      style: TextStyle(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.white.withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // =========================
              // CREAR CUENTA
              // =========================

              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person_add_alt_1,
                  size: 19,
                ),
                label: const Text(
                  '¿No tienes cuenta? · Crear cuenta',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                '❄️  ENTRENA · AVANZA · DISFRUTA  ❄️',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}