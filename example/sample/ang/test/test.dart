// @TestOn('browser')

// import 'package:angular_test/angular_test.dart';
// import "package:example.ang/app_component.dart";
// import 'package:test/test.dart';
// import 'test.template.dart' as ng;
// void main() {
//   ng.initReflector();
//   final testBed = new NgTestBed<AppComponent>();
//   NgTestFixture<AppComponent> fixture;
//   setUp(() async {
//     fixture = await testBed.create();
//   });
//   tearDown(disposeAnyRunningTest);

//   test('Default greeting', () {
//     expect(fixture.text, 'Hello Angular');
//   });

//   test('Greet world', () async {
//     await fixture.update((c) => c.hero.name = 'World');
//     expect(fixture.text, 'Hello World');
//   });

//   test('Greet world HTML', () {
//     final html = fixture.rootElement.innerHtml;
//     expect(html, '<h1>Hello Angular</h1>');
//   });
// }
