import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/biometric_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final auth = AuthService();

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    final name = await auth.getName();
    final age = await auth.getAge();
    final height = await auth.getHeight();
    final weight = await auth.getWeight();

    if (!mounted) return;

    nameController.text = name;
    ageController.text = age > 0 ? age.toString() : '';
    heightController.text =
    height > 0 ? height.toString().replaceAll('.0', '') : '';
    weightController.text =
    weight > 0 ? weight.toString().replaceAll('.0', '') : '';

    setState(() {
      loading = false;
    });
  }

  Future<void> saveProfile() async {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());
    final height = double.tryParse(
      heightController.text.trim().replaceAll(',', '.'),
    );
    final weight = double.tryParse(
      weightController.text.trim().replaceAll(',', '.'),
    );

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

    if (age == null || age < 1 || age > 100) {
      showMessage(
        'La edad debe estar entre 1 y 100 años.',
      );
      return;
    }

    if (height == null || height < 1 || height > 300) {
      showMessage(
        'La estatura debe estar entre 1 y 300 cm.',
      );
      return;
    }

    if (weight == null || weight < 1 || weight > 200) {
      showMessage(
        'El peso debe estar entre 1 y 200 kg.',
      );
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      await auth.updateProfile(
        name: name,
        age: age,
        height: height,
        weight: weight,
      );

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showMessage('Perfil actualizado correctamente.');
    } catch (_) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      showMessage(
        'No se pudo actualizar el perfil.',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PERFIL',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: AppTheme.surface,
            child: Icon(
              Icons.person,
              color: AppTheme.lime,
              size: 42,
            ),
          ),

          const SizedBox(height: 15),

          Center(
            child: Text(
              nameController.text.isEmpty
                  ? 'Atleta PULSE'
                  : nameController.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 4),

          const Center(
            child: Text(
              'Perfil protegido con biometría',
              style: TextStyle(
                color: AppTheme.muted,
              ),
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'DATOS PERSONALES',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
                    onChanged: (_) {
                      setState(() {});
                    },
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

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed:
                      saving ? null : saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor:
                        AppTheme.lime,
                        foregroundColor:
                        Colors.black,
                      ),
                      icon: saving
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                          : const Icon(
                        Icons.save_outlined,
                      ),
                      label: Text(
                        saving
                            ? 'GUARDANDO...'
                            : 'GUARDAR CAMBIOS',
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.fingerprint,
                color: AppTheme.lime,
              ),
              title: const Text(
                'Verificar huella',
              ),
              subtitle: const Text(
                'Confirma la biometría registrada en el teléfono',
              ),
              onTap: () async {
                final ok =
                await BiometricService().authenticate();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Identidad verificada.'
                          : 'No se pudo validar.',
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'PULSE FIT procesa los datos de sensores localmente. '
                    'La huella nunca se almacena en la aplicación.',
                style: TextStyle(
                  color: AppTheme.muted,
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            onPressed: () async {
              await AuthService().logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (_) => false,
              );
            },
            icon: const Icon(
              Icons.lock_outline,
            ),
            label: const Text(
              'CERRAR SESIÓN',
            ),
          ),
        ],
      ),
    );
  }
}