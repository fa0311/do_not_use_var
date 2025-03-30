import 'package:do_not_use_var/src/do_not_use_var.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group("serializeCode", () {
    test("string", () {
      final code = serializeCode("Hello World");
      expect(code, '"Hello World"');
    });
    test("function", () {
      final code = serializeCode(() => print("Hello World"));
      expect(code, '() => print("Hello World")');
    });
  });

  test("test", () async {
    await expectFixture(
      DoNotUseVarLint(),
      DoNotUseVarForLoopFix(),
      () {
        for (var i = 0; i < 10; i++) {
          print(i);
        }
      },
      () {
        for (final i in Iterable.generate(10)) {
          print(i);
        }
      },
    );
  });
}
