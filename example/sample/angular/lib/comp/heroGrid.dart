// import 'dart:async';

import 'package:angular/angular.dart';

import '../model/model.dart';
import '../service/service.dart';
import "package:angular_router/angular_router.dart";
import 'dart:html';
import 'package:slickdart/slick_custom.dart';
import 'package:slickdart/slick.dart';
// import 'dart:math';

// import '../route_path.dart' as paths;

@Component(
  selector: 'hero-grid',
  templateUrl: 'heroGrid.html',
  styleUrls: ['heroGrid.css'],
  directives: [
    coreDirectives,
  ],
  providers: const [coreDirectives],
  pipes: [commonPipes],
)
class HeroGridComponent implements AfterViewInit {
  CsvAdapter csv;
  String filterStr;
  final MyService _service;
  final Router _router;
  static List<Hero> heroes;
  @ViewChild('grid')
  Element gridEl;
  HeroGridComponent(this._service, this._router);
  JGrid gw0;

  initGrid() async {
    List<Column> cols;
    csv = await _service.getGridData();
    cols = getColDefs(csv.columns);
    cols[1]
      ..width = 20
      ..name = 'id';
    csv.columns[0]
      ..width = 14
      ..name = 'id';
    Map opt = {
      'multiColumnSort': true,
      'editable': false,
    };
    gw0 = JGrid(gridEl);
    gw0.init(MetaList(csv.data, getMeta), cols, option: opt);
    gw0.grid.onSort.subscribe((EventData e, EvtArgs parm) {
      hash.clear();
      gw0.grid.invalidate();
    });
  }

  Map<String, String> getMeta(int row) {
    var rdata = csv.data[row];
    if (rdata['gss_code'] == filterStr) {
      hash[row] = {'UNITID': 'bold', 'school_id': 'bold'};
      return {"cssClasses": "highlight"};
    } else
      return {}; // {"cssClasses":'highlight'};
  }

  void ngAfterViewInit() => initGrid();
}

Map<int, Map<String, String>> hash = {};
List<Column> getColDefs(List<Column> cols) {
  List<Column> newCols =
      cols.map((col) => new Column.fromColumn(col)..sortable = true).toList();
  CheckboxSelectColumn checkboxCol =
      new CheckboxSelectColumn({'cssClass': "slick-cell-checkboxsel"});
  newCols.insert(0, checkboxCol.getColumnDefinition());
  return newCols;
}
