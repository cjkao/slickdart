// // import 'dart:async';

// import 'package:angular/angular.dart';

// import '../model/model.dart';
// import '../service/service.dart';
// import "package:angular_router/angular_router.dart";
// import 'dart:html';
// import 'package:slickdart/slick_custom.dart';
// import 'package:slickdart/slick.dart';
// import 'package:angular_components/material_icon/material_icon.dart';
// import 'package:angular_components/material_button/material_button.dart';
// import 'package:angular_components/material_input/material_input.dart';
// // import 'dart:math';

// // import '../route_path.dart' as paths;

// @Component(
//   selector: 'hero-grid',
//   templateUrl: 'heroGrid.html',
//   styleUrls: ['heroGrid.css'],
//   directives: [
//     coreDirectives,
//     MaterialIconComponent,
//     MaterialInputComponent,
//     MaterialButtonComponent,
//   ],
//   providers: const [coreDirectives, NgModel],
//   pipes: [commonPipes],
// )
// class HeroGridComponent implements AfterViewInit {
//   CsvAdapter csv;
//   String filterStr;
//   final MyService _service;
//   final Router _router;
//   static List<Hero> heroes;
//   @ViewChild('grid')
//   Element gridEl;
//   HeroGridComponent(this._service, this._router);
//   JGrid gw0;
//   Map curValue = {};
//   MetaList metaList;
//   initGrid() async {
//     List<Column> cols;
//     csv = await _service.getGridData();
//     cols = getColDefs(csv.columns);
//     cols[1]
//       ..width = 20
//       ..name = 'id';
//     csv.columns[0]
//       ..width = 14
//       ..name = 'id';
//     Map opt = {
//       'multiColumnSort': true,
//       'editable': false,
//     };
//     print(gridEl);
//     gw0 = JGrid(gridEl);
//     metaList = MetaList(csv.data, getMeta);
//     gw0.init(metaList, cols, option: opt);
//     gw0.grid.onSort.subscribe((EventData e, EvtArgs parm) {
//       hash.clear();
//       gw0.grid.invalidate();
//     });
//     gw0.grid.onSelectedRowsChanged.subscribe(rowChange);
//   }

//   void rowChange(EventData e, EvtArgs parm) {
//     print(parm);
//     if ((parm["rows"] as List).length > 0) {
//       curValue = metaList[parm["rows"][0]];
//     }
//   }

//   Map<String, String> getMeta(int row) {
//     var rdata = csv.data[row];
//     if (rdata['gss_code'] == filterStr) {
//       hash[row] = {'UNITID': 'bold', 'school_id': 'bold'};
//       return {"cssClasses": "highlight"};
//     } else
//       return {}; // {"cssClasses":'highlight'};
//   }

//   bool showGrid = true;
//   void ngAfterViewInit() => initGrid();
//   void hideGrid() {
//     showGrid = !showGrid;
//   }

//   void updateRec() {
//     metaList.first["gss_code"] = "1234";
//     gw0.grid.invalidate();
//     gw0.grid.render();
//   }
// }

// Map<int, Map<String, String>> hash = {};
// List<Column> getColDefs(List<Column> cols) {
//   List<Column> newCols =
//       cols.map((col) => new Column.fromColumn(col)..sortable = true).toList();
//   CheckboxSelectColumn checkboxCol =
//       new CheckboxSelectColumn({'cssClass': "slick-cell-checkboxsel"});
//   newCols.insert(0, checkboxCol.getColumnDefinition());
//   return newCols;
// }
