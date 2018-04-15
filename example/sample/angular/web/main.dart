import 'package:angular/angular.dart';

import 'main.template.dart' as ng;
import "package:example.ang/app_component.dart" as myapp;
import "package:example.ang/app_component.template.dart" as myapp_gen;
import 'package:angular_router/angular_router.dart';

void main() {
  bootstrapStatic(LoadingComponent, [], ng.initReflector);
  bootstrapStatic(myapp.AppComponent, [routerProvidersHash], ng.initReflector);
}

@Component(
  selector: 'load-world',
  template: 'Loading World....',
)
class LoadingComponent {}
