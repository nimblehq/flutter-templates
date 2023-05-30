import 'package:mason/mason.dart';

import 'bundles/permission_handler_bundle.dart';

Future<void> run(HookContext context) async {
  try {
    final newVars = {};
    if (context.vars['add_permission_handler'] == true) {
      newVars.addAll(await addPermissionHandlerVariables());
    }
    context.vars = {...context.vars, ...newVars};
  } catch (e) {
    context.logger.err(e.toString());
  }
}

Future<Map<String, dynamic>> addPermissionHandlerVariables() async {
  Map<String, dynamic> newVars = {};
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
      newVars.putIfAbsent(formattedName, () => String.fromCharCodes(content));
    }
  });
  return Future.value(newVars);
}
