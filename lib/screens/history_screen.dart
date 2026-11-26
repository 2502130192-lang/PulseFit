
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/workout_model.dart';
import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final db = DatabaseService();
  late Future<List<WorkoutModel>> future;

  @override
  void initState() {
    super.initState();
    future = db.getWorkouts();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'MI HISTORIAL',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: FutureBuilder<List<WorkoutModel>>(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final items = snapshot.data!;

        if (items.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.history,
                  size: 55,
                  color: AppTheme.muted,
                ),
                SizedBox(height: 12),
                Text('Aún no hay entrenamientos guardados.'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(18),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final w = items[i];
            final date = w.date.toLocal();
            final duration = Duration(
              seconds: w.durationSeconds,
            );

            return Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.lime,
                  child: Icon(
                    Icons.directions_run,
                    color: Colors.black,
                  ),
                ),
                title: Text(
                  '${w.steps} pasos',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${date.day}/${date.month}/${date.year}  •  '
                      '${duration.inMinutes} min  •  '
                      '${(w.distanceMeters / 1000).toStringAsFixed(2)} km\n'
                      '${w.route.length} puntos GPS',
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    ),
  );
}
