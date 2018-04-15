import 'dart:html';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });

  cj.SlickGrid grid = prepareGrid();
  grid.init();
  querySelector('#reset').onClick.listen((e) {
    grid.data = makeData(50000);
    grid.invalidate();
  });
}

List makeData(int len) {
  List _data = [];
  for (var i = 0; i < len; i++) {
    _data.add({
      'title': i,
      'duration':  math.Random().nextInt(20),
      'percent': i%10,
      'pc': ( math.Random().nextInt(10) * 100).toString(),
      'start': "01/01/2009",
      'finish': ( math.Random().nextInt(10) + 10).toString() + "/05/2013",
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
    cj.Column.fromMap({'field': "pc", 'name': "D", 'editor': 'TextEditor', 'sortable':true}),
    cj.Column.fromMap({'field': "effortDriven", 'name': "E", 'width': 200})
  ];
  cj.CheckboxSelectColumn checkboxCol = cj.CheckboxSelectColumn({'cssClass': "slick-cell-checkboxsel"});
  column.insert(0, checkboxCol.getColumnDefinition());
  var opt =  cj.GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = true
    ..editable = true
    ..autoEdit = true
    ..enableAddRow = true
    ..leaveSpaceForNewRows = true
    //..showTopPanel=true
    //..topPanelHeight=50
    ..frozenColumn =1
    ..frozenRow = 1
    ..enableColumnReorder = true
    ..enableTextSelectionOnCells=true;

  cj.SlickGrid sg =  cj.SlickGrid.fromOpt(el, makeData(50), column, opt);
  sg.setSelectionModel(cj.RowSelectionModel({'selectActiveRow': false}));
  sg.registerPlugin(checkboxCol);
  sg.registerPlugin(new AutoTooltips());

  //sg.setSelectionModel(newCellSelectionModel(sg.options));
  //args: {rows:[...], grid: SlickGrid }
  sg.onSelectedRowsChanged.subscribe((cj.EventData e, Map args) {
    querySelector('.right-pane')
      ..children.clear()
      ..appendText((args['rows'] as List).join(' '));
  });

  sg.onSort.subscribe((e, args) {
    var cols = args['sortCols'];
//{sortCol: {name: Title1, resizable: true, sortable: true, minWidth: 30, rerenderOnResize: false, headerCssClass: null, defaultSortAsc: true, focusable: true, selectable: true, cannotTriggerInsert: false, width: 80, id: title, field: title}, sortAsc: true}
    sg.getData().sort((dataRow1, dataRow2) {
      for (var i = 0, l = cols.length; i < l; i++) {




        var field = cols[i]['sortCol']['field'];
        var sign = cols[i]['sortAsc'] ? 1 : -1;
        dynamic value1 = dataRow1[field], value2 = dataRow2[field];
        if (field == 'dtitle') {
          return value1 == value2 ? 0 : (int.parse(value1) > int.parse(value2) ? 1 : -1) * sign;
        }
        var result = (value1 == value2 ? 0 : (value1.compareTo(value2) > 0 ? 1 : -1)) * sign;
        if (result != 0) {
          return result;
        }
      }
      return 0;
    });
    sg.invalidate();
  });
  return sg;
}
