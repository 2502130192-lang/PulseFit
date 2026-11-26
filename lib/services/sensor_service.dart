import 'dart:async';
import 'dart:math' as math;
import 'package:pedometer/pedometer.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorService {
  StreamSubscription<StepCount>? _stepsSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  int? _baseSteps;
  int steps = 0;
  double x = 0, y = 0, z = 9.8;
  double gx = 0, gy = 0, gz = 0;
  double intensity = 0;
  String movement = 'En espera';

  void start({
    required void Function() onUpdate,
    required void Function(String) onError,
  }) {
    try {
      _stepsSub = Pedometer.stepCountStream.listen((event) {
        _baseSteps ??= event.steps;
        steps = math.max(0, event.steps - _baseSteps!);
        onUpdate();
      }, onError: (_) => onError('El podómetro no está disponible en este dispositivo.'));
    } catch (_) { onError('No se pudo iniciar el podómetro.'); }

    try {
      _accelSub = accelerometerEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      ).listen((event) {
        x = event.x; y = event.y; z = event.z;
        intensity = math.sqrt(x*x + y*y + z*z);
        final dynamicAcceleration = (intensity - 9.8).abs();
        movement = dynamicAcceleration < 0.8 ? 'Descanso'
          : dynamicAcceleration < 2.8 ? 'Caminata' : 'Trote / actividad intensa';
        onUpdate();
      }, onError: (_) => onError('Acelerómetro no disponible.'));
    } catch (_) { onError('No se pudo iniciar el acelerómetro.'); }

    try {
      _gyroSub = gyroscopeEventStream(
        samplingPeriod: SensorInterval.normalInterval,
      ).listen((event) {
        gx = event.x; gy = event.y; gz = event.z;
        onUpdate();
      }, onError: (_) => onError('Giroscopio no disponible.'));
    } catch (_) { onError('No se pudo iniciar el giroscopio.'); }
  }

  Future<void> stop() async {
    await _stepsSub?.cancel(); _stepsSub = null;
    await _accelSub?.cancel(); _accelSub = null;
    await _gyroSub?.cancel(); _gyroSub = null;
  }

  void resetSession() { _baseSteps = null; steps = 0; }
}
