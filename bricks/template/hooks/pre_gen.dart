import 'dart:io';

import 'package:mason/mason.dart';

import 'bundles/permission_handler_bundle.dart';

Future<void> run(HookContext context) async {
  // Clean up the output folder, even at the root, to have only the final generated project in the end
  print("> Clean up the output folder (pre): " + Directory.current.path);
  final entities = Directory.current.listSync(recursive: false);
  final exclusions = [
    // we should not delete .git
    Directory.current.path + '/.git',
    // the bricks folder can be deleted at post_gen only
    Directory.current.path + '/bricks',
  ];
  await deleteFileSystemEntities(entities, exclusions: exclusions);

  try {
    final additionalVars = {};
    if (context.vars['add_permission_handler'] == true) {
      additionalVars.addAll(await addPermissionHandlerVariables());
    }
    context.vars = {...context.vars, ...additionalVars};
  } catch (e) {
    context.logger.err(e.toString());
  }
}

Future<Map<String, dynamic>> addPermissionHandlerVariables() async {
  Map<String, dynamic> vars = {};
  final generator = await MasonGenerator.fromBundle(permissionHandlerBundle);
  generator.partials.forEach((filePath, content) {
    if (filePath.startsWith('{{~ _')) {
      // Remove the special characters from the partial files
      final formattedName = filePath
          .replaceAll('{', '')
          .replaceAll('}', '')
          .replaceAll('~ ', '')
          .replaceAll('.', '')
          .trim();
      vars.putIfAbsent(formattedName, () => String.fromCharCodes(content));
    }
  });
  return vars;
}

Future<void> deleteFileSystemEntities(
  List<FileSystemEntity> entities, {
  List<String> exclusions = const [],
}) async {
  entities.forEach((entity) {
    if (entity.existsSync() && !exclusions.contains(entity.path)) {
      print('Delete ' + entity.path);
      if (entity is File) {
        entity.deleteSync();
      } else if (entity is Directory) {
        entity.deleteSync(recursive: true);
      }
    }
  });
}
