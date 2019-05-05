import 'dart:io';
import 'package:sass/sass.dart' as sass;

void main(List<String> arguments) {
  if (arguments.length != 2) {
    print(
        "dart bin/compile-sass.dart example/sample/gdoc.scss example/sample/gdoc.css");
  } else {
    var result = sass.compile(arguments[0]);
    new File(arguments[1]).writeAsStringSync(result);
  }
}
