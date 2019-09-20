// import 'package:angular/angular.dart';
// import 'package:angular_components/angular_components.dart';
// import 'package:angular_components/app_layout/material_persistent_drawer.dart';
// import 'package:angular_components/content/deferred_content.dart';
// import 'package:angular_components/material_button/material_button.dart';
// import 'package:angular_components/material_icon/material_icon.dart';
// import 'package:angular_components/material_list/material_list.dart';
// import 'package:angular_components/material_list/material_list_item.dart';
// import 'package:angular_components/material_toggle/material_toggle.dart';
// import "../service/service.dart";
// import "../service/logger.dart";
// //import "multi.dart";
// //import "comp/heroList.dart";
// import "../model/model.dart";
// import "package:angular_router/angular_router.dart";
// import "../route_path.dart";

// @Component(
//   selector: 'my-drawer',
//   templateUrl: "package:example.ang/comp/drawer.html",
//   styleUrls: const [
//     'package:angular_components/app_layout/layout.scss.css',
//     'package:example.ang/comp/drawer.css'
//   ],
//   directives: [
//     MaterialButtonComponent,
//     DeferredContentDirective,
//     MaterialButtonComponent,
//     MaterialIconComponent,
//     MaterialPersistentDrawerDirective,
//     MaterialToggleComponent,
//     MaterialListComponent,
//     MaterialListItemComponent,
//     coreDirectives,
//   ],
//   providers: const [materialProviders],
// )
// class AppDrawer {
//   final title = 'Heroes';
//   MyService _service;
//   Logger _logger;
//   Router _router;
//   AppDrawer(this._service, this._logger, this._router);
//   bool hasHero() => _service.selectedHero != null;
//   Hero get hero => _service.selectedHero;
//   void gotoMulti() {
//     _router.navigate(multi.toUrl());
//   }

//   void gotoGrid() => _router.navigate(heroGrid.toUrl());
// }
