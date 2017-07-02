import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;
import 'package:slickdart/slick_cell_selection.dart';
import 'package:slickdart/slick_column.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  grid.SlickGrid g = buildGrid();
  g.init();
  querySelector('#reset').onClick.listen((e) {
    List _data = [];
    for (var i = 0; i < 500000; i++) {
      _data.add({
        'idi': i,
        'title': new math.Random().nextInt(1000).toString(),
        'duration': new math.Random().nextInt(1000).toString(),
        'pc': i
      });
    }
    g.data = _data;
    g.invalidate();
    g.render();
  });
  querySelector('#check-multi').onClick.listen((MouseEvent evt) {
    InputElement checkbox = evt.target;
    if (!checkbox.checked) {
      g.setSelectedRows([]);
      g.gridOptions.multiSelect = false;
    } else {
      g.gridOptions.multiSelect = true;
    }
    g.invalidate();
    g.render();
  });
  querySelector('#del').onClick.listen((MouseEvent evt) {
    var arr = [];
    g.getSelectedRows().forEach((_) => arr.add(g.data[_]));
    arr.forEach((_) => g.data.remove(_));
    g.setSelectedRows([]);
    g.invalidate();
    g.render();
  });
}

grid.SlickGrid buildGrid() {
  Element el = querySelector('#grid');
  List<grid.Column> column = new ColumnList.fromMap([
    {'width': 130, 'field': "idi", 'name': 'ID', 'sortable': true, 'editor': 'TextEditor'},
    {'width': 120, 'field': "duration", 'sortable': true},
    {'field': "pc", 'sortable': true},
    {'width': 400, 'field': "finish"}
  ]);
  //CheckboxSelectColumn checkboxCol=new CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
  //column.insert(0,checkboxCol.getColumnDefinition());
  List data = [];
  for (var i = 0; i < 50; i++) {
    data.add({
      'title': new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100).toString(),
      'pc': new math.Random().nextInt(10) * 100,
      'idi': i + 1,
      'finish': (new math.Random().nextInt(10) + 10).toString() + "/05/2013",
    });
  }

  var opt = new grid.GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = true
    ..multiSelect = false
    ..autoEdit = false
    ..enableColumnReorder = false
    ..frozenColumn = 0;
  grid.SlickGrid sg = new grid.SlickGrid.fromOpt(el, data, column, opt);
  var cellSelectModel = new CellSelectionModel();
  cellSelectModel.onSelectedRangesChanged.subscribe((var e, args) {
    cellSelectModel.getSelectedRanges().forEach(print);
  });
  sg.setSelectionModel(cellSelectModel);
  //sg.registerPlugin(checkboxCol);
  //sg.setSelectionModel(new CellSelectionModel(sg.options));

  sg.onSort.subscribe(grid.basicSorter);
  return sg;
}
