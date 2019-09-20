// ignore_for_file: uri_has_not_been_generated
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../route_path.dart' as paths;
import '../comp/heroList.template.dart' as hlct;
// import '../comp/heroGrid.template.dart' deferred as gd;
// import '../comp/multi.template.dart' as mul;
// import "dart:async";

@Injectable()
class Routes {
  static final _heroes = RouteDefinition(
    routePath: paths.heroes,
    component: hlct.HeroListComponentNgFactory,
  );
static final hero = RouteDefinition(
  routePath: RoutePaths.hero,
  component: hero_template.HeroComponentNgFactory,
);
//   static final _heroGrid =  RouteDefinition.defer(
//       routePath: paths.heroGrid, loader: loadGridView);

//   static final _multi =  RouteDefinition(
//     routePath: paths.multi,
//     component: mul.MaterialDropdownSelectDemoComponentNgFactory,
//   );
  RouteDefinition get heroes => _heroes;
//   RouteDefinition get multi => _multi;
//   RouteDefinition get herogrid => _heroGrid;

  // final List<RouteDefinition> all = [_heroes, _multi, _heroGrid];
  final List<RouteDefinition> all = [
    _heroes,
  ];
// }

// // defer grid loading
// Future<ComponentFactory> loadGridView() async {
//   await gd.loadLibrary();
//   return gd.HeroGridComponentNgFactory;
}
