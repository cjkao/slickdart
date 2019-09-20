import 'package:angular/angular.dart';
import 'main.template.dart' as self;
import "package:example.ang/app_component.template.dart" as ng;
// import "package:example.ang/app_component.template.dart" as myapp_gen;
import 'package:angular_router/angular_router.dart';
// import 'package:slickdart/slick_custom.dart';

@GenerateInjector(
  routerProvidersHash, // You can use routerProviders in production
)
final InjectorFactory injector = self.injector$Injector;
void main() {
  // registerElem();
  runApp(ng.AppComponentNgFactory, createInjector: injector);
  // myApp.initReflector();
  // bootstrapStatic(
  // myApp.AppComponent, [routerProvidersHash], self.initReflector);

  // runApp(myApp.AppComponentNgFactory );//, [routerProvidersHash], ng.initReflector);
}
