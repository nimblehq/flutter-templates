import 'dart:io';

import 'package:mason/mason.dart';

import 'bundles/permission_handler_bundle.dart';

Future<void> run(HookContext context) async {
  try {
    await generateBricks(context);
  } catch (e) {
    context.logger.err(e.toString());
  }
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
