import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;

      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      final available = await isAvailable();

      if (!available) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Confirma tu identidad para entrar a PULSE FIT',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}