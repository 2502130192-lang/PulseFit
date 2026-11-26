import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _accountsKey = 'pulse_fit_accounts';
  static const String _sessionKey = 'logged_in';
  static const String _currentEmailKey = 'current_user_email';
  static const String _lastBiometricEmailKey =
      'last_biometric_email';

  Future<List<Map<String, dynamic>>> _getAccounts() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_accountsKey);

    if (raw == null || raw.isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        return [];
      }

      return decoded
          .map(
            (e) => Map<String, dynamic>.from(e),
      )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAccounts(
      List<Map<String, dynamic>> accounts,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _accountsKey,
      jsonEncode(accounts),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required int age,
    required double height,
    required double weight,
  }) async {
    if (age < 1 || age > 100) {
      return false;
    }

    if (height < 1 || height > 300) {
      return false;
    }

    if (weight < 1 || weight > 200) {
      return false;
    }

    final normalizedEmail = email.trim().toLowerCase();

    final accounts = await _getAccounts();

    final alreadyExists = accounts.any(
          (account) =>
      account['email']?.toString().toLowerCase() ==
          normalizedEmail,
    );

    if (alreadyExists) {
      return false;
    }

    final newAccount = <String, dynamic>{
      'name': name.trim(),
      'email': normalizedEmail,
      'password': password,
      'age': age,
      'height': height,
      'weight': weight,
    };

    accounts.add(newAccount);

    await _saveAccounts(accounts);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _lastBiometricEmailKey,
      normalizedEmail,
    );

    await prefs.setBool(_sessionKey, false);

    return true;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final accounts = await _getAccounts();

    for (final account in accounts) {
      final savedEmail =
          account['email']?.toString().toLowerCase() ?? '';

      final savedPassword =
          account['password']?.toString() ?? '';

      if (normalizedEmail == savedEmail &&
          password == savedPassword) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool(_sessionKey, true);

        await prefs.setString(
          _currentEmailKey,
          savedEmail,
        );

        await prefs.setString(
          _lastBiometricEmailKey,
          savedEmail,
        );

        return true;
      }
    }

    return false;
  }

  Future<bool> hasRegisteredAccount() async {
    final accounts = await _getAccounts();

    return accounts.isNotEmpty;
  }

  Future<bool> biometricLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final lastEmail =
    prefs.getString(_lastBiometricEmailKey);

    if (lastEmail == null || lastEmail.isEmpty) {
      return false;
    }

    final accounts = await _getAccounts();

    for (final account in accounts) {
      final email =
          account['email']?.toString().toLowerCase() ?? '';

      if (email == lastEmail.toLowerCase()) {
        await prefs.setBool(_sessionKey, true);

        await prefs.setString(
          _currentEmailKey,
          email,
        );

        return true;
      }
    }

    return false;
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_sessionKey) ?? false;
  }

  Future<String> getCurrentEmail() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_currentEmailKey) ?? '';
  }

  Future<Map<String, dynamic>?> _getCurrentAccount() async {
    final currentEmail = await getCurrentEmail();

    if (currentEmail.isEmpty) {
      return null;
    }

    final accounts = await _getAccounts();

    for (final account in accounts) {
      final email =
          account['email']?.toString().toLowerCase() ?? '';

      if (email == currentEmail.toLowerCase()) {
        return account;
      }
    }

    return null;
  }

  Future<String> getName() async {
    final account = await _getCurrentAccount();

    return account?['name']?.toString() ?? 'Atleta PULSE';
  }

  Future<String> getEmail() async {
    return getCurrentEmail();
  }

  Future<int> getAge() async {
    final account = await _getCurrentAccount();

    final value = account?['age'];

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return 0;
  }

  Future<double> getHeight() async {
    final account = await _getCurrentAccount();

    final value = account?['height'];

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  Future<double> getWeight() async {
    final account = await _getCurrentAccount();

    final value = account?['weight'];

    if (value is num) {
      return value.toDouble();
    }

    return 0;
  }

  Future<void> updateProfile({
    required String name,
    required int age,
    required double height,
    required double weight,
  }) async {
    if (age < 1 || age > 100) {
      throw Exception('Edad fuera de rango.');
    }

    if (height < 1 || height > 300) {
      throw Exception('Estatura fuera de rango.');
    }

    if (weight < 1 || weight > 200) {
      throw Exception('Peso fuera de rango.');
    }

    final currentEmail = await getCurrentEmail();

    if (currentEmail.isEmpty) {
      throw Exception('No hay una sesión activa.');
    }

    final accounts = await _getAccounts();

    bool updated = false;

    for (int i = 0; i < accounts.length; i++) {
      final email =
          accounts[i]['email']?.toString().toLowerCase() ?? '';

      if (email == currentEmail.toLowerCase()) {
        accounts[i]['name'] = name.trim();
        accounts[i]['age'] = age;
        accounts[i]['height'] = height;
        accounts[i]['weight'] = weight;

        updated = true;
        break;
      }
    }

    if (!updated) {
      throw Exception('No se encontró la cuenta.');
    }

    await _saveAccounts(accounts);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_sessionKey, false);

    await prefs.remove(_currentEmailKey);
  }
}