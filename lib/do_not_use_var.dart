import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:do_not_use_var/src/do_not_use_var.dart';

PluginBase createPlugin() => _ExampleLinter();

class _ExampleLinter extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        DoNotUseVarLint(),
      ];
}
