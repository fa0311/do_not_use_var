import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart' show Trace;
import 'package:test/test.dart';

String serializeCode(
  dynamic _, {
  int depth = 1,
  String name = "serializeCode",
  int offset = 0,
}) {
  final frame = Trace.current().frames[depth];
  final result = parseFile(
    path: frame.uri.toFilePath(),
    featureSet: FeatureSet.latestLanguageVersion(),
    throwIfDiagnostics: false,
  );
  final functionsViditor = MethodInvocationVisitor(name);
  result.unit.visitChildren(functionsViditor);
  final self = functionsViditor.functions.firstWhere((element) {
    return result.lineInfo.getLocation(element.offset).lineNumber == frame.line;
  });
  return self.argumentList.arguments[offset].toSource();
}

class MethodInvocationVisitor extends RecursiveAstVisitor<void> {
  MethodInvocationVisitor(this.name);
  final String name;
  final functions = <MethodInvocation>[];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    super.visitMethodInvocation(node);
    if (node.methodName.name == name) {
      functions.add(node);
    }
  }
}

expectFixture(
  DartLintRule lint,
  DartFix fix,
  void Function() a,
  void Function() b,
) async {
  final temp = Directory.systemTemp.createTempSync("do_not_use_var_");
  try {
    final file = File(path.join(temp.path, "main.dart"));
    wrap(String code) => "void main$code";

    final code = serializeCode(a, depth: 2, offset: 2, name: "expectFixture");
    final wrappedCode = wrap(code);
    await file.writeAsString(wrappedCode);
    final analysisError = await lint.testAnalyzeAndRun(file);
    final changes = await fix.testAnalyzeAndRun(
      file,
      analysisError.first,
      analysisError,
    );

    final res = SourceEdit.applySequence(
      wrappedCode,
      changes.expand((e) => e.change.edits.expand((e) => e.edits)),
    );
    final exp = serializeCode(b, depth: 2, offset: 3, name: "expectFixture");
    final wrappedExp = wrap(exp);
    expect(res, wrappedExp);
  } finally {
    //temp.deleteSync(recursive: true);
  }
}
