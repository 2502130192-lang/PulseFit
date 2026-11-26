import 'dart:convert';
import 'package:latlong2/latlong.dart';

class WorkoutModel {
  final String id;
  final DateTime date;
  final int durationSeconds;
  final int steps;
  final double distanceMeters;
  final List<LatLng> route;

  WorkoutModel({
    required this.id, required this.date, required this.durationSeconds,
    required this.steps, required this.distanceMeters, required this.route,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'date': date.toIso8601String(),
    'durationSeconds': durationSeconds, 'steps': steps,
    'distanceMeters': distanceMeters,
    'route': route.map((p) => [p.latitude, p.longitude]).toList(),
  };

  factory WorkoutModel.fromMap(Map<String, dynamic> map) => WorkoutModel(
    id: map['id'], date: DateTime.parse(map['date']),
    durationSeconds: map['durationSeconds'], steps: map['steps'],
    distanceMeters: (map['distanceMeters'] as num).toDouble(),
    route: (map['route'] as List)
      .map((p) => LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble()))
      .toList(),
  );

  static String encode(List<WorkoutModel> items) =>
      jsonEncode(items.map((e) => e.toMap()).toList());
  static List<WorkoutModel> decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List)
        .map((e) => WorkoutModel.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) { return []; }
  }
}
