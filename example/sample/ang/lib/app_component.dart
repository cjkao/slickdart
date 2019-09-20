import 'package:angular/angular.dart';
// import 'package:example.ang/model/model.dart';
// import 'package:angular_forms/angular_forms.dart';
// import 'package:angular_components/angular_components.dart';
// // import 'package:angular_components/app_layout/material_temporary_drawer.dart';
// import 'package:angular_components/app_layout/material_persistent_drawer.dart';
// import 'package:angular_components/content/deferred_content.dart';
// import 'package:angular_components/material_button/material_button.dart';
// import 'package:angular_components/material_icon/material_icon.dart';
// import 'package:angular_components/material_list/material_list.dart';
// import 'package:angular_components/material_list/material_list_item.dart';
// import 'package:angular_components/material_toggle/material_toggle.dart';
import "service/service.dart";
// import "service/logger.dart";
// import "comp/multi.dart";
import "comp/heroList.dart";
// import "comp/drawer.dart";
import 'service/route.dart';
import 'package:angular_router/angular_router.dart';

@Component(
  selector: 'my-app',
  templateUrl: "package:example.ang/app_component.html",
  styleUrls: const [
    'package:angular_components/app_layout/layout.scss.css',
    'package:example.ang/app_component.css'
  ],
  directives: [
    // formDirectives,
    // MaterialButtonComponent,
    // DeferredContentDirective,
    // MaterialButtonComponent,
    // MaterialIconComponent,
    // MaterialPersistentDrawerDirective,
    // // MaterialTemporaryDrawerComponent,
    // // MaterialToggleComponent,
    // // MaterialListComponent,
    // // MaterialListItemComponent,
    // // MaterialDropdownSelectDemoComponent,
    // coreDirectives,
    routerDirectives,
    HeroListComponent,
    // AppDrawer,
  ],
  providers: const [
    // materialProviders,
    const ClassProvider(MyService),
    // Logger,
    const ClassProvider(Routes),
  ],
)
class AppComponent implements OnInit {
  final title = 'Tour of Grids';
  bool customWidth = false;
  bool end = false;
  final Routes routes;

  // Hero hero;
  // final MyService myService;
  AppComponent(this.routes);
  // @ViewChild(AppDrawer)
  // AppDrawer drawer;
  @override
  void ngOnInit() async {
    // heroes = await myService.getHeroes();
  }

//  void selectHero(Hero hero) {
//    this.hero = hero;
//  }
}
