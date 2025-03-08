import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  /// Request multiple permissions
  static Future<bool> requestMultiplePermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.sms,
      Permission.contacts,
      Permission.camera,
      Permission.storage,
      Permission.phone,
    ].request();

    // Check if all permissions are granted
    return statuses.values.every((status) => status.isGranted);
  }
}
