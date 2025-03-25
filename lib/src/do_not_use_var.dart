import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:analyzer/error/listener.dart' show ErrorReporter;
import 'package:analyzer/error/listener.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class DoNotUseVarLint extends DartLintRule {
  DoNotUseVarLint() : super(code: _code);

  static const _code = LintCode(
    name: 'do_not_use_var',
    problemMessage: 'Avoid using `var`. Use `final` instead.',
  );

  @override
  List<Fix> getFixes() => [
        DoNotUseVarLintFix(),
        DoNotUseVarForLoopFix(),
      ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addVariableDeclarationList((VariableDeclarationList node) {
      if (node.keyword?.lexeme == 'var') {
        reporter.atNode(node, _code);
      }
    });
  }
}

class DoNotUseVarLintFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addVariableDeclarationList((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;
      final nodeKeyword = node.keyword;
      if (nodeKeyword == null) return;
      if (nodeKeyword.lexeme != 'var') return;

      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace `var` with `final`',
        priority: 1,
      );

      changeBuilder.addDartFileEdit((builder) {
        builder.addSimpleReplacement(
          SourceRange(nodeKeyword.offset, nodeKeyword.length),
          'final',
        );
      });
    });
  }
}

extension on VariableDeclarationList {
  VariableDeclaration get one {
    return variables.first;
  }
}

class DoNotUseVarForLoopFix extends DartFix {
  @override
  void run(
    CustomLintResolver resolver,
    ChangeReporter reporter,
    CustomLintContext context,
    AnalysisError analysisError,
    List<AnalysisError> others,
  ) {
    context.registry.addForPartsWithDeclarations((node) {
      if (!analysisError.sourceRange.intersects(node.sourceRange)) return;
      final condition = node.condition;
      if (condition is! BinaryExpression) return;
      if (node.variables.keyword?.lexeme != 'var') return;
      if (!condition.operator.lexeme.contains('<')) return;
      final initializer = node.variables.one.initializer;
      if (initializer == null) return;

      // for (var i = 0; i < 10; i++)  ->  for (final i in Iterable.generate(10))
      // for (var i = 1; i < 10; i++)  ->  for (final i in Iterable.generate(10, (i) => i + 1))
      final changeBuilder = reporter.createChangeBuilder(
        message: 'Replace `var` with `final` in for-loop',
        priority: 2,
      );

      changeBuilder.addDartFileEdit((builder) {
        final conditionRightOperand = condition.rightOperand;
        final startValue = initializer.toSource();
        final endValue = conditionRightOperand.toSource();

        final iterableExpression = startValue == '0'
            ? 'Iterable.generate($endValue)'
            : 'Iterable.generate($endValue, (i) => i + $startValue)';

        builder.addSimpleReplacement(
          SourceRange(node.offset, node.length),
          'for (final ${node.variables.variables.first.name.toString()} in $iterableExpression)',
        );
      });
    });
  }
}
