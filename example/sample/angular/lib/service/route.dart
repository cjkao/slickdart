// ignore_for_file: uri_has_not_been_generated
import 'package:angular/angular.dart';
import 'package:angular_router/angular_router.dart';

import '../route_path.dart' as paths;
import '../comp/heroList.template.dart' as hlct;
import '../comp/multi.template.dart' as mul;

@Injectable()
class Routes {
  static final _heroes = new RouteDefinition(
    routePath: paths.heroes,
    component: hlct.HeroListComponentNgFactory,
  );
  static final _multi = new RouteDefinition(
    routePath: paths.multi,
    component: mul.MaterialDropdownSelectDemoComponentNgFactory,
  );
  RouteDefinition get heroes => _heroes;
  RouteDefinition get multi => _multi;

  final List<RouteDefinition> all = [_heroes, _multi];
}
