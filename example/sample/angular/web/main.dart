import 'package:angular/angular.dart';

import 'main.template.dart' as self;
import "package:example.ang/app_component.template.dart" as myApp;
// import "package:example.ang/app_component.template.dart" as myapp_gen;
import 'package:angular_router/angular_router.dart' ;
import 'package:slickdart/slick_custom.dart';



// @GenerateInjector(
//   routerProvidersHash, // You can use routerProviders in production
// )
// final InjectorFactory injector = self.injector;
void main() {
  registerElem();
  runApp(self.LoadingComponentNgFactory );
  // myApp.initReflector();
  bootstrapStatic(myApp.AppComponent, [routerProvidersHash], self.initReflector);

  // runApp(myApp.AppComponentNgFactory );//, [routerProvidersHash], ng.initReflector);
}

@Component(
  selector: 'load-world',
  template: 'Loading World....',
)
class LoadingComponent {}
