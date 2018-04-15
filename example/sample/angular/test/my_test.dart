@TestOn('browser')
import "package:angular/angular.dart";
import 'package:test/test.dart';
import 'my_test.template.dart' as ng;
import 'package:angular_test/angular_test.dart';

void main() {
  ng.initReflector();
  tearDown(disposeAnyRunningTest);

  test('should render "Hello World"', () async {
    final testBed = new NgTestBed<HelloWorldComponent>();
    final testFixture = await testBed.create();
    expect(testFixture.text, 'Hello World');
    await testFixture.update((c) => c.name = 'Universe');
    expect(testFixture.text, 'Hello Universe');
  });
}

@Component(selector: 'test', template: 'Hello {{name}}')
class HelloWorldComponent {
  String name = 'World';
}
