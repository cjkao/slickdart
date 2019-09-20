import 'package:angular_router/angular_router.dart';

final dashboard = RoutePath(path: 'dashboard');
final multi = RoutePath(path: 'multi');
final heroes = RoutePath(path: 'heroes');
final heroGrid = RoutePath(path: 'herogrid');
const idParam = 'id';
final hero = RoutePath(path: '${heroes.path}/:$idParam');
