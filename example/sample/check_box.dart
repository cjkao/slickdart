import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;

void main() {
  grid.SlickGrid g = init();
  g.init();
  querySelector('#reset').onClick.listen((e) {
    List _data = [];
    for (var i = 0; i < 500000; i++) {
      _data.add(
          {'idi': i, 'title': math.Random().nextInt(1000).toString(), 'duration': math.Random().nextInt(1000).toString(), 'pc': i});
    }
//    g.data.clear();
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

grid.SlickGrid init() {
  Element el = querySelector('#grid');
  List<grid.Column> column = grid.ColumnList.fromMap([
    {'width': 130, 'field': "idi", 'name': 'ID', 'sortable': true, 'editor': 'TextEditor'},
    {'width': 120, 'field': "duration", 'sortable': true},
    {'field': "pc", 'sortable': true},
    {'width': 400, 'field': "finish"}
  ]);
  grid.CheckboxSelectColumn checkboxCol = grid.CheckboxSelectColumn({'cssClass': "slick-cell-checkboxsel"});
  column.insert(0, checkboxCol.getColumnDefinition());
  List data = [];
  for (var i = 0; i < 50; i++) {
    data.add({
      'title': math.Random().nextInt(100).toString(),
      'duration': math.Random().nextInt(100).toString(),
      'pc': math.Random().nextInt(10) * 100,
      'idi': i + 1,
      'finish': (math.Random().nextInt(10) + 10).toString() + "/05/2013",
    });
  }

  var opt = grid.GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = true
    ..multiSelect = false
    ..autoEdit = false
    ..enableColumnReorder = true
    ..frozenColumn = 2;
  grid.SlickGrid sg = grid.SlickGrid.fromOpt(el, data, column, opt);
  grid.RowSelectionModel rsm = grid.RowSelectionModel({'selectActiveRow': true});
  sg.onSelectedRowsChanged.subscribe((var e, args) {
    rsm.getSelectedRows().forEach(print);
  });
  sg.setSelectionModel(rsm);
  sg.registerPlugin(checkboxCol);
  //sg.setSelectionModel( CellSelectionModel(sg.options));

  sg.onSort.subscribe(grid.basicSorter);
  return sg;
}
