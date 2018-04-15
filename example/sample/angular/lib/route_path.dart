import 'package:angular_router/angular_router.dart';

final dashboard = new RoutePath(path: 'dashboard');
final multi = new RoutePath(path: 'multi');
final heroes = new RoutePath(path: 'heroes');
const idParam = 'id';
final hero = new RoutePath(path: '${heroes.path}/:$idParam');
