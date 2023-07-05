import 'package:mason/mason.dart';

import 'bundles/permission_handler_bundle.dart';

Future<void> run(HookContext context) async {
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
