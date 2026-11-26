import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/theme/app_theme.dart';
import '../models/workout_model.dart';
import '../services/sensor_service.dart';
import '../services/location_service.dart';
import '../services/permission_service.dart';
import '../services/database_service.dart';
import '../services/auth_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen>
    with WidgetsBindingObserver {
  final sensors = SensorService();
  final gps = LocationService();
  final permissions = PermissionService();
  final database = DatabaseService();
  final auth = AuthService();
  final mapController = MapController();

  bool running = false;
  bool saving = false;
  String status = 'Sesión detenida';

  int seconds = 0;
  Timer? timer;
  DateTime? startedAt;

  // =========================
  // DATOS DEL USUARIO
  // =========================

  double weightKg = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    loadUserWeight();
  }

  // =========================
  // CARGAR PESO
  // =========================

  Future<void> loadUserWeight() async {
    final weight = await auth.getWeight();

    if (!mounted) return;

    setState(() {
      weightKg = weight;
    });
  }

  // =========================
  // ACTUALIZAR PANTALLA
  // =========================

  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  // =========================
  // MENSAJES
  // =========================

  void message(String value) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value),
        ),
      );
    }
  }

  // =========================
  // INICIAR ENTRENAMIENTO
  // =========================

  Future<void> startWorkout() async {
    final activityOk = await permissions.requestActivity();
    final locationOk = await permissions.requestLocation();

    if (!activityOk) {
      message(
        'Se necesita permiso de actividad física para contar pasos.',
      );
      return;
    }

    if (!locationOk) {
      message(
        'Se necesita ubicación para registrar el recorrido.',
      );
      return;
    }

    // Volver a cargar el peso por si cambió.
    await loadUserWeight();

    sensors.resetSession();
    gps.reset();

    startedAt = DateTime.now();
    seconds = 0;

    sensors.start(
      onUpdate: update,
      onError: message,
    );

    final gpsOk = await gps.start(
      update,
      message,
    );

    if (!gpsOk) {
      await sensors.stop();
      return;
    }

    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) {
        if (mounted) {
          setState(() {
            seconds++;
          });
        }
      },
    );

    if (mounted) {
      setState(() {
        running = true;
        status = 'Entrenamiento activo';
      });
    }
  }

  // =========================
  // DETENER ENTRENAMIENTO
  // =========================

  Future<void> stopWorkout({
    bool save = true,
  }) async {
    timer?.cancel();
    timer = null;

    await sensors.stop();
    await gps.stop();

    if (save &&
        startedAt != null &&
        (seconds > 0 || sensors.steps > 0)) {
      if (mounted) {
        setState(() {
          saving = true;
        });
      }

      final workout = WorkoutModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        date: startedAt!,
        durationSeconds: seconds,
        steps: sensors.steps,
        distanceMeters: gps.distanceMeters,
        route: List.of(gps.route),
      );

      await database.saveWorkout(workout);

      if (mounted) {
        setState(() {
          saving = false;
        });
      }

      message(
        'Entrenamiento guardado en tu historial.',
      );
    }

    if (mounted) {
      setState(() {
        running = false;
        status = 'Sesión finalizada';
      });
    }
  }

  // =========================
  // CICLO DE VIDA
  // =========================

  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (running) {
        stopWorkout(save: true);
      }
    }
  }

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    timer?.cancel();

    sensors.stop();
    gps.stop();

    super.dispose();
  }

  // =========================
  // TIEMPO
  // =========================

  String get clock {
    final h = (seconds ~/ 3600)
        .toString()
        .padLeft(2, '0');

    final m = ((seconds % 3600) ~/ 60)
        .toString()
        .padLeft(2, '0');

    final s = (seconds % 60)
        .toString()
        .padLeft(2, '0');

    return '$h:$m:$s';
  }

  // =========================
  // CALORÍAS ESTIMADAS
  // =========================

  double get caloriesBurned {
    final distanceKm = gps.distanceMeters / 1000;

    if (weightKg <= 0 || distanceKm <= 0) {
      return 0;
    }

    // Estimación sencilla para caminata:
    // peso (kg) × distancia (km) × 0.5
    return weightKg * distanceKm * 0.5;
  }

  // =========================
  // PANTALLA
  // =========================

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'ENTRENAMIENTO',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    ),
    body: ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // =========================
        // ESTADO Y TIEMPO
        // =========================

        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: running
                    ? AppTheme.lime
                    : AppTheme.muted,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 9),
            Text(
              status,
              style: const TextStyle(
                color: AppTheme.muted,
              ),
            ),
            const Spacer(),
            Text(
              clock,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // =========================
        // PASOS Y DISTANCIA
        // =========================

        Row(
          children: [
            Expanded(
              child: _Metric(
                title: 'PASOS',
                value: '${sensors.steps}',
                icon: Icons.directions_walk,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                title: 'DISTANCIA',
                value:
                '${(gps.distanceMeters / 1000).toStringAsFixed(2)} km',
                icon: Icons.route,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // =========================
        // VELOCIDAD Y MOVIMIENTO
        // =========================

        Row(
          children: [
            Expanded(
              child: _Metric(
                title: 'VELOCIDAD',
                value:
                '${gps.speedKmh.toStringAsFixed(1)} km/h',
                icon: Icons.speed,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                title: 'MOVIMIENTO',
                value: sensors.movement,
                icon: Icons.directions_run,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // =========================
        // CALORÍAS Y PESO
        // =========================

        Row(
          children: [
            Expanded(
              child: _Metric(
                title: 'CALORÍAS',
                value:
                '${caloriesBurned.toStringAsFixed(0)} kcal',
                icon: Icons.local_fire_department,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Metric(
                title: 'PESO',
                value:
                '${weightKg.toStringAsFixed(1)} kg',
                icon: Icons.monitor_weight_outlined,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // =========================
        // MAPA
        // =========================

        const Text(
          'MAPA EN TIEMPO REAL',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 10),

        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: 260,
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter:
                gps.current ??
                    const LatLng(
                      20.268,
                      -98.943,
                    ),
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName:
                  'com.example.pulse_fit',
                ),

                if (gps.route.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: gps.route,
                        strokeWidth: 5,
                        color: AppTheme.lime,
                      ),
                    ],
                  ),

                if (gps.current != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: gps.current!,
                        width: 42,
                        height: 42,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.red,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 18),

        // =========================
        // TELEMETRÍA
        // =========================

        const Text(
          'TELEMETRÍA DE SENSORES',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 10),

        _SensorPanel(
          title: 'ACELERÓMETRO · m/s²',
          values:
          'X  ${sensors.x.toStringAsFixed(2)}     '
              'Y  ${sensors.y.toStringAsFixed(2)}     '
              'Z  ${sensors.z.toStringAsFixed(2)}',
          subtitle:
          'Intensidad total: '
              '${sensors.intensity.toStringAsFixed(2)}',
        ),

        const SizedBox(height: 10),

        _SensorPanel(
          title: 'GIROSCOPIO · rad/s',
          values:
          'X  ${sensors.gx.toStringAsFixed(2)}     '
              'Y  ${sensors.gy.toStringAsFixed(2)}     '
              'Z  ${sensors.gz.toStringAsFixed(2)}',
          subtitle:
          'Velocidad angular por eje',
        ),

        const SizedBox(height: 22),

        // =========================
        // BOTÓN
        // =========================

        SizedBox(
          height: 55,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor:
              running
                  ? Colors.redAccent
                  : AppTheme.lime,
              foregroundColor:
              running
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: saving
                ? null
                : (running
                ? () => stopWorkout()
                : startWorkout),
            icon: Icon(
              running
                  ? Icons.stop
                  : Icons.play_arrow,
            ),
            label: Text(
              saving
                  ? 'GUARDANDO...'
                  : (running
                  ? 'FINALIZAR Y GUARDAR'
                  : 'INICIAR SESIÓN'),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Al salir de esta pantalla o pasar a segundo plano, '
              'los sensores se pausan y la sesión se guarda.',
          style: TextStyle(
            color: AppTheme.muted,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

// =====================================================
// WIDGET DE MÉTRICA
// =====================================================

class _Metric extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _Metric({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.lime,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ),
  );
}

// =====================================================
// PANEL DE SENSORES
// =====================================================

class _SensorPanel extends StatelessWidget {
  final String title;
  final String values;
  final String subtitle;

  const _SensorPanel({
    required this.title,
    required this.values,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.lime,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            values,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  );
}