import 'dart:html';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin.dart';
import 'package:logging/logging.dart';

cj.SlickGrid grid;
void main() {
  Logger.root.level = Level.WARNING;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  querySelector('#grid').hidden = true;
  querySelector('#reset').onClick.listen((e) {
    grid = prepareGrid();
    grid.init();
    grid.data = makeData(50000);
    grid.invalidate();
    grid.container.style.display = 'block';
  });
  querySelector('#del').onClick.listen((e) {
    grid.unSubscribe();
    grid.container.children.clear();
    grid.container.hidden = true;
  });
}

List makeData(int len) {
  List _data = [];
  for (var i = 0; i < len; i++) {
    _data.add({
      'title': i,
      'duration': math.Random().nextInt(100),
      'percent': '${i % 100}%',
      'pc': (math.Random().nextInt(10) * 100).toString(),
      'start': "01/01/2009",
      'finish': (math.Random().nextInt(10) + 10).toString() + "/05/2013",
      'effortDriven': (i % 5 == 0)
    });
  }
  return _data;
}

cj.SlickGrid prepareGrid() {
  Element el = querySelector('#grid');
  List<cj.Column> column = [
    cj.Column.fromMap({'field': "title", 'name': "FIXED", 'sortable': true}),
    cj.Column.fromMap({'field': "duration", 'name': "A", 'width': 120, 'sortable': true, 'editor': 'IntEditor'}),
    cj.Column.fromMap({'field': "percent", 'name': 'B', 'sortable': true, 'editor': 'TextEditor'}),
    cj.Column.fromMap({'field': "finish", 'name': "C"}),
    cj.Column.fromMap({'field': "pc", 'name': "D", 'editor': 'TextEditor'}),
    cj.Column.fromMap({'field': "effortDriven", 'name': "E", 'width': 200})
  ];
  cj.CheckboxSelectColumn checkboxCol = cj.CheckboxSelectColumn({'cssClass': "slick-cell-checkboxsel"});
  column.insert(0, checkboxCol.getColumnDefinition());
  var opt = cj.GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = true
    ..editable = true
    ..autoEdit = true
    ..enableAddRow = true
    ..leaveSpaceForNewRows = true
    //..showTopPanel=true
    //..topPanelHeight=50
    ..frozenColumn = 1
    ..frozenRow = 1
    ..enableColumnReorder = true
    ..enableTextSelectionOnCells = true;

  cj.SlickGrid sg = cj.SlickGrid.fromOpt(el, makeData(50), column, opt);
  sg.setSelectionModel(cj.RowSelectionModel({'selectActiveRow': false}));
  sg.registerPlugin(checkboxCol);
  sg.registerPlugin(AutoTooltips());

  //sg.setSelectionModel( CellSelectionModel(sg.options));
  //args: {rows:[...], grid: SlickGrid }
  sg.onSelectedRowsChanged.subscribe((cj.EventData e, Map args) {
    querySelector('.right-pane')
      ..children.clear()
      ..appendText((args['rows'] as List).join(' '));
  });

  return sg;
}
