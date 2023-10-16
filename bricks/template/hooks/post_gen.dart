import 'dart:io';

import 'package:mason/mason.dart';

import 'bundles/permission_handler_bundle.dart';
import 'hooks_util.dart';

Future<void> run(HookContext context) async {
  try {
    await generateBricks(context);
  } catch (e) {
    context.logger.err(e.toString());
  }

  // Clean up the output folder, even at the root, to have only the final generated project in the end
  print("> Clean up the output folder (post): " + Directory.current.path);
  final List<FileSystemEntity> entities = [
    Directory(Directory.current.path + '/bricks'),
  ];
  await deleteFileSystemEntities(entities);
}

Future<void> generateBricks(HookContext context) async {
  if (context.vars['add_permission_handler'] == true) {
    await generatePermissionHandlerBrick(context.vars['project_name']);
  }
}

Future<void> generatePermissionHandlerBrick(String projectName) async {
  final generator = await MasonGenerator.fromBundle(permissionHandlerBundle);
  await generator.generate(DirectoryGeneratorTarget(Directory.current),
      vars: {'project_name': projectName});
}
