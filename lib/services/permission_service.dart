import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestActivity() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }
}
