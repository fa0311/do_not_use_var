import 'package:quiver/iterables.dart';

void main() {
  var a = [1, 2, 3];
  // bad
  print(a[0]);
  for (var i = 0; i < 10; i++) {
    print(i);
  }

  // good
  for (final i in Iterable.generate(10)) {
    print(i);
  }

  // use  quiver
  // good

  for (final i in range(10)) {
    print(i);
  }
}
