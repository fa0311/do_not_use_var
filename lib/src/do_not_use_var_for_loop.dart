// import 'package:analyzer/dart/ast/ast.dart';
// import 'package:analyzer/error/error.dart' hide LintCode;
// import 'package:analyzer/error/listener.dart' show ErrorReporter;
// import 'package:analyzer/error/listener.dart';
// import 'package:analyzer/source/source_range.dart';
// import 'package:custom_lint_builder/custom_lint_builder.dart';

// class DoNotUseVarForLoopLint extends DartLintRule {
//   DoNotUseVarForLoopLint() : super(code: _code);

//   static const _code = LintCode(
//     name: 'do_not_use_var',
//     problemMessage: 'Avoid using `var`. Use `final` instead.',
//   );

//   @override
//   List<Fix> getFixes() => [
//         DoNotUseVarForLoopFix(),
//       ];

//   @override
//   void run(
//     CustomLintResolver resolver,
//     ErrorReporter reporter,
//     CustomLintContext context,
//   ) {
//     context.registry.addVariableDeclarationList((VariableDeclarationList node) {
//       if (node.keyword?.lexeme == 'var') {
//         reporter.atNode(node, _code);
//       }
//     });
//   }
// }

// class DoNotUseVarForLoopFix extends DartFix {
//   @override
//   void run(
//     CustomLintResolver resolver,
//     ChangeReporter reporter,
//     CustomLintContext context,
//     AnalysisError analysisError,
//     List<AnalysisError> others,
//   ) {
//     context.registry.addForStatement((node) {
//       if (!analysisError.sourceRange.intersects(node.sourceRange)) return;

//       final forLoopParts = node.forLoopParts;
//       if (forLoopParts is ForPartsWithDeclarations &&
//           forLoopParts.variables.keyword?.lexeme == 'var') {
//         final changeBuilder = reporter.createChangeBuilder(
//           message: 'Replace `var` with `final` in for-loop',
//           priority: 2,
//         );

//         changeBuilder.addDartFileEdit((builder) {
//           final nodeKeyword = forLoopParts.variables.keyword;
//           if (nodeKeyword != null) {
//             builder.addSimpleReplacement(
//               SourceRange(nodeKeyword.offset, nodeKeyword.length),
//               'final',
//             );
//           }
//         });
//       }
//     });
//   }
// }
