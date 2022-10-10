import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

abstract class PermissionWrapper {
  Future<bool> requestCameraPermission();

  Future<bool> isCameraPermissionDenied();

  Future<bool> isCameraPermissionPermanentlyDenied();

  Future<bool> requestGalleryPermission();

  Future<bool> isGalleryPermissionDenied();

  Future<bool> isGalleryPermissionPermanentlyDenied();

  Future<bool> openAppSettings();
}

@Singleton(as: PermissionWrapper)
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

  @override
  Future<bool> isGalleryPermissionDenied() {
    return permission_handler.Permission.photos.isDenied;
  }

  @override
  Future<bool> isGalleryPermissionPermanentlyDenied() {
    return permission_handler.Permission.photos.isPermanentlyDenied;
  }

  @override
  Future<bool> requestGalleryPermission() {
    return permission_handler.Permission.photos
        .request()
        .then((value) => value == permission_handler.PermissionStatus.granted);
  }

  @override
  Future<bool> openAppSettings() {
    return permission_handler.openAppSettings();
  }
}
