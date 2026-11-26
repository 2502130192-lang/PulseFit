import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../widgets/festive_background.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final auth = AuthService();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  bool get hasMinLength {
    return passwordController.text.length >= 8;
  }

  bool get hasUppercase {
    return RegExp(r'[A-Z]').hasMatch(passwordController.text);
  }

  bool get hasLowercase {
    return RegExp(r'[a-z]').hasMatch(passwordController.text);
  }

  bool get hasNumber {
    return RegExp(r'[0-9]').hasMatch(passwordController.text);
  }

  bool get hasSpecial {
    return RegExp(
      r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\]]',
    ).hasMatch(passwordController.text);
  }

  bool get passwordsMatch {
    return passwordController.text.isNotEmpty &&
        passwordController.text == confirmController.text;
  }

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final ageText = ageController.text.trim();
    final heightText = heightController.text.trim();
    final weightText = weightController.text.trim();
    final password = passwordController.text;
    final confirm = confirmController.text;

    if (name.isEmpty) {
      showMessage('Escribe tu nombre.');
      return;
    }

    final validName = RegExp(
      r'^[a-zA-ZÁÉÍÓÚáéíóúÑñÜü\s]+$',
    );

    if (!validName.hasMatch(name)) {
      showMessage(
        'El nombre solo puede contener letras y espacios.',
      );
      return;
    }

    if (email.isEmpty) {
      showMessage('Escribe tu correo.');
      return;
    }

    final validEmail = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!validEmail.hasMatch(email)) {
      showMessage('Escribe un correo válido.');
      return;
    }

    if (ageText.isEmpty) {
      showMessage('Escribe tu edad.');
      return;
    }

    final age = int.tryParse(ageText);

    if (age == null || age < 1 || age > 100) {
      showMessage(
        'La edad debe estar entre 1 y 100 años.',
      );
      return;
    }

    if (heightText.isEmpty) {
      showMessage('Escribe tu estatura.');
      return;
    }

    final height = double.tryParse(
      heightText.replaceAll(',', '.'),
    );

    if (height == null || height < 1 || height > 300) {
      showMessage(
        'La estatura debe estar entre 1 y 300 cm.',
      );
      return;
    }

    if (weightText.isEmpty) {
      showMessage('Escribe tu peso.');
      return;
    }

    final weight = double.tryParse(
      weightText.replaceAll(',', '.'),
    );

    if (weight == null || weight < 1 || weight > 200) {
      showMessage(
        'El peso debe estar entre 1 y 200 kg.',
      );
      return;
    }

    if (password.isEmpty) {
      showMessage('Escribe una contraseña.');
      return;
    }

    if (!hasMinLength ||
        !hasUppercase ||
        !hasLowercase ||
        !hasNumber ||
        !hasSpecial) {
      showMessage(
        'La contraseña no cumple todos los requisitos.',
      );
      return;
    }

    if (confirm.isEmpty) {
      showMessage('Confirma tu contraseña.');
      return;
    }

    if (password != confirm) {
      showMessage('Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await auth.register(
        name: name,
        email: email,
        password: password,
        age: age,
        height: height,
        weight: weight,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      if (result) {
        showMessage('Cuenta creada correctamente.');

        await Future.delayed(
          const Duration(milliseconds: 700),
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      } else {
        showMessage('No se pudo crear la cuenta.');
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        'Ocurrió un error al registrar la cuenta.',
      );
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  InputDecoration inputDecoration({
    required String label,
    required IconData icon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixText: suffixText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  Widget passwordRequirement(
      String text,
      bool valid,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            valid
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            size: 16,
            color: valid
                ? AppTheme.lime
                : AppTheme.muted,
          ),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              color: valid
                  ? AppTheme.lime
                  : AppTheme.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FestiveBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.person_add_alt_1,
                          color: AppTheme.lime,
                          size: 48,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'CREAR CUENTA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'Crea tu perfil de PULSE FIT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.muted,
                          ),
                        ),

                        const SizedBox(height: 24),

                        TextField(
                          controller: nameController,
                          textCapitalization:
                          TextCapitalization.words,
                          keyboardType: TextInputType.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(
                                r'[a-zA-ZÁÉÍÓÚáéíóúÑñÜü\s]',
                              ),
                            ),
                          ],
                          decoration: inputDecoration(
                            label: 'Nombre completo',
                            icon: Icons.person_outline,
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: emailController,
                          keyboardType:
                          TextInputType.emailAddress,
                          decoration: inputDecoration(
                            label: 'Correo electrónico',
                            icon: Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // EDAD: 1 - 100
                        TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                if (newValue.text.isEmpty) {
                                  return newValue;
                                }

                                if (!RegExp(r'^\d+$')
                                    .hasMatch(newValue.text)) {
                                  return oldValue;
                                }

                                final value =
                                int.tryParse(newValue.text);

                                if (value != null &&
                                    value >= 1 &&
                                    value <= 100) {
                                  return newValue;
                                }

                                return oldValue;
                              },
                            ),
                          ],
                          decoration: inputDecoration(
                            label: 'Edad',
                            icon: Icons.cake_outlined,
                            suffixText: 'años',
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ESTATURA: 1 - 300 CM
                        TextField(
                          controller: heightController,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                if (newValue.text.isEmpty) {
                                  return newValue;
                                }

                                final text =
                                newValue.text.replaceAll(
                                  ',',
                                  '.',
                                );

                                if (!RegExp(
                                  r'^\d{0,3}([.]\d{0,2})?$',
                                ).hasMatch(text)) {
                                  return oldValue;
                                }

                                if (text == '.') {
                                  return oldValue;
                                }

                                final value =
                                double.tryParse(text);

                                if (value != null &&
                                    value >= 1 &&
                                    value <= 300) {
                                  return newValue;
                                }

                                if (text.endsWith('.')) {
                                  final number = double.tryParse(
                                    text.substring(
                                      0,
                                      text.length - 1,
                                    ),
                                  );

                                  if (number != null &&
                                      number >= 1 &&
                                      number <= 300) {
                                    return newValue;
                                  }
                                }

                                return oldValue;
                              },
                            ),
                          ],
                          decoration: inputDecoration(
                            label: 'Estatura',
                            icon: Icons.height,
                            suffixText: 'cm',
                          ),
                        ),

                        const SizedBox(height: 14),

                        // PESO: 1 - 200 KG
                        TextField(
                          controller: weightController,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                                  (oldValue, newValue) {
                                if (newValue.text.isEmpty) {
                                  return newValue;
                                }

                                final text =
                                newValue.text.replaceAll(
                                  ',',
                                  '.',
                                );

                                if (!RegExp(
                                  r'^\d{0,3}([.]\d{0,2})?$',
                                ).hasMatch(text)) {
                                  return oldValue;
                                }

                                if (text == '.') {
                                  return oldValue;
                                }

                                final value =
                                double.tryParse(text);

                                if (value != null &&
                                    value >= 1 &&
                                    value <= 200) {
                                  return newValue;
                                }

                                if (text.endsWith('.')) {
                                  final number = double.tryParse(
                                    text.substring(
                                      0,
                                      text.length - 1,
                                    ),
                                  );

                                  if (number != null &&
                                      number >= 1 &&
                                      number <= 200) {
                                    return newValue;
                                  }
                                }

                                return oldValue;
                              },
                            ),
                          ],
                          decoration: inputDecoration(
                            label: 'Peso',
                            icon: Icons.monitor_weight_outlined,
                            suffixText: 'kg',
                          ),
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          onChanged: (_) {
                            setState(() {});
                          },
                          decoration: inputDecoration(
                            label: 'Contraseña',
                            icon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                  !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Text(
                          'La contraseña debe contener:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        passwordRequirement(
                          'Mínimo 8 caracteres',
                          hasMinLength,
                        ),

                        passwordRequirement(
                          'Una letra mayúscula',
                          hasUppercase,
                        ),

                        passwordRequirement(
                          'Una letra minúscula',
                          hasLowercase,
                        ),

                        passwordRequirement(
                          'Un número',
                          hasNumber,
                        ),

                        passwordRequirement(
                          'Un símbolo especial',
                          hasSpecial,
                        ),

                        const SizedBox(height: 14),

                        TextField(
                          controller: confirmController,
                          obscureText: obscureConfirm,
                          onChanged: (_) {
                            setState(() {});
                          },
                          decoration: inputDecoration(
                            label: 'Confirmar contraseña',
                            icon: Icons.lock_reset_outlined,
                          ).copyWith(
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscureConfirm =
                                  !obscureConfirm;
                                });
                              },
                              icon: Icon(
                                obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),

                        if (confirmController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  passwordsMatch
                                      ? Icons.check_circle
                                      : Icons.error,
                                  size: 17,
                                  color: passwordsMatch
                                      ? AppTheme.lime
                                      : Colors.redAccent,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  passwordsMatch
                                      ? 'Las contraseñas coinciden'
                                      : 'Las contraseñas no coinciden',
                                  style: TextStyle(
                                    color: passwordsMatch
                                        ? AppTheme.lime
                                        : Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 22),

                        SizedBox(
                          height: 54,
                          child: FilledButton(
                            onPressed:
                            loading ? null : register,
                            style: FilledButton.styleFrom(
                              backgroundColor:
                              AppTheme.lime,
                              foregroundColor:
                              Colors.black,
                            ),
                            child: loading
                                ? const SizedBox(
                              width: 23,
                              height: 23,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              'CREAR CUENTA',
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextButton(
                          onPressed: loading
                              ? null
                              : () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            '¿Ya tienes una cuenta? Inicia sesión',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}