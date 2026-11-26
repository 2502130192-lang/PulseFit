import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  StreamSubscription<Position>? _sub;

  final List<LatLng> route = [];

  double distanceMeters = 0;
  double speedKmh = 0;
  LatLng? current;

  Future<bool> start(
      void Function() onUpdate,
      void Function(String) onError,
      ) async {
    try {
      // Verificar que el GPS esté encendido.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        onError('Activa el GPS del teléfono.');
        return false;
      }

      // Revisar permisos.
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        onError('No se concedió el permiso de ubicación.');
        return false;
      }

      if (permission == LocationPermission.deniedForever) {
        onError(
          'El permiso de ubicación está bloqueado. '
              'Actívalo desde los ajustes del teléfono.',
        );
        return false;
      }

      // Si ya había una sesión anterior, cancelarla.
      await _sub?.cancel();
      _sub = null;

      // Obtener una primera posición inmediatamente.
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
          ),
        );

        final point = LatLng(
          position.latitude,
          position.longitude,
        );

        current = point;

        // La primera posición es el punto inicial.
        if (route.isEmpty) {
          route.add(point);
        }

        speedKmh =
        position.speed.isFinite && position.speed > 0
            ? position.speed * 3.6
            : 0;

        onUpdate();
      } catch (_) {
        // Si falla la primera posición, continuamos con el stream.
      }

      // Escuchar cambios de ubicación.
      _sub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 3,
        ),
      ).listen(
            (position) {
          final point = LatLng(
            position.latitude,
            position.longitude,
          );

          // Calcular distancia desde el último punto.
          if (route.isNotEmpty) {
            final last = route.last;

            final delta = Geolocator.distanceBetween(
              last.latitude,
              last.longitude,
              point.latitude,
              point.longitude,
            );

            /*
             * Ignoramos movimientos demasiado pequeños,
             * porque normalmente son ruido del GPS.
             *
             * También evitamos saltos GPS exagerados.
             */
            if (delta >= 2 && delta <= 500) {
              distanceMeters += delta;
              route.add(point);
            }
          } else {
            route.add(point);
          }

          current = point;

          // Convertir m/s a km/h.
          if (position.speed.isFinite && position.speed > 0) {
            speedKmh = position.speed * 3.6;
          } else {
            speedKmh = 0;
          }

          onUpdate();
        },
        onError: (_) {
          onError('Se perdió la señal GPS.');
        },
      );

      return true;
    } catch (_) {
      onError('No se pudo iniciar la ubicación.');
      return false;
    }
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  void reset() {
    route.clear();
    distanceMeters = 0;
    speedKmh = 0;
    current = null;
  }

  String get distanceKmText {
    final kilometers = distanceMeters / 1000;

    if (kilometers < 1) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    }

    return '${kilometers.toStringAsFixed(2)} km';
  }
}