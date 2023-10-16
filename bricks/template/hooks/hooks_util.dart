import 'dart:io';

Future<void> deleteFileSystemEntities(List<FileSystemEntity> entities) async {
  entities.forEach((entity) {
    if (entity.existsSync()) {
      print('Delete ' + entity.path);
      if (entity is File) {
        entity.deleteSync();
      } else if (entity is Directory) {
        entity.deleteSync(recursive: true);
      }
    }
  });
}
