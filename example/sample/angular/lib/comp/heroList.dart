import 'dart:async';

import 'package:angular/angular.dart';

import '../model/model.dart';
import '../service/service.dart';
import "package:angular_router/angular_router.dart";
import '../route_path.dart' as paths;

@Component(
  selector: 'hero-list',
  templateUrl: 'heroList.html',
  styleUrls: ['heroList.css'],
  directives: [
    coreDirectives,
  ],
  providers: const [coreDirectives],
  pipes: [commonPipes],
)
class HeroListComponent implements OnInit {
  Hero hero;
  final MyService _service;
  final Router _router;
  static List<Hero> heroes;
  HeroListComponent(this._service, this._router);

  Future<void> _getHeroes() async {
    heroes ??= await _service.getHeroes();
  }

  void onSelect(Hero hero) {
    this.hero = hero;
    _service.selectedHero = hero;
  }

  void ngOnInit() => _getHeroes();
  String _heroUrl(int id) =>
      paths.hero.toUrl(parameters: {paths.idParam: id.toString()});
  void gotoDetail() {
    _router.navigate(_heroUrl(hero.id));
  }
}
