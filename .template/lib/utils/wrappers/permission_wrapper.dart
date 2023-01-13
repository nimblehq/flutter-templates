import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

abstract class PermissionWrapper {
  Future<bool> requestCameraPermission();

  Future<bool> isCameraPermissionDenied();

  Future<bool> isCameraPermissionPermanentlyDenied();
}

class PermissionWrapperImpl extends PermissionWrapper {
  @override
  Future<bool> requestCameraPermission() {
    return permission_handler.Permission.camera
        .request()
        .then((value) => value == permission_handler.PermissionStatus.granted);
  }

  @override
  Future<bool> isCameraPermissionDenied() {
    return permission_handler.Permission.camera.isDenied;
  }

  @override
  Future<bool> isCameraPermissionPermanentlyDenied() {
    return permission_handler.Permission.camera.isPermanentlyDenied;
  }
}
