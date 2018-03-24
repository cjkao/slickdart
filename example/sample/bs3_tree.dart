library bs3.tree;

import 'dart:html';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin.dart';
import 'dart:collection';

cj.HierarchFilterList _data =
    cj.HierarchFilterList.withKeyField("_parent", "id", "_collapsed");
void main() {
  cj.SlickGrid grid = prepareGrid();
  grid.init();
  querySelector('#reset').onClick.listen((e) {
    grid.data = makeData(50000);
    grid.invalidate();
  });
  querySelector('#slider1').onChange.listen((Event e) {
    num minVal = (e.currentTarget as InputElement).valueAsNumber;
    _data.addKeyword('percentComplete', (double val) {
      if (val >= minVal) return true;
      return false;
    });
    grid.invalidate();
  });
}

List makeData(int len) {
//  _data=[];
  var indent = 0;
  Queue parents = Queue();
  ;
  var rand = math.Random(1);
  for (int i = 0; i < len; i++) {
    var row = {};
    _data.add(row);
    // var d = (_data[i] = {});
    int parent;
    if (rand.nextDouble() > 0.8 && i > 0) {
      indent++;
      parents.addLast(i - 1);
    } else if (rand.nextDouble() < 0.3 && indent > 0) {
      indent--;
      parents.removeLast();
    }

    if (parents.length > 0) {
      parent = parents.last;
    } else {
      parent = null;
    }
    row["id"] = i;
    row["indent"] = indent;
    row["_parent"] = parent;
    row["title"] = "Task $i";
    row["duration"] = "5 days";
    row["percentComplete"] = rand.nextDouble() * 100;
    row["start"] = "01/01/2009";
    row["finish"] = "01/05/2009";
    row["effortDriven"] = (i % 5 == 0);
    row["_collapsed"] = false;
  }
  _data.addKeyword("_collapsed", false);
  return _data;
}

cj.SlickGrid prepareGrid() {
  Element el = querySelector('#grid');
  List<cj.Column> column = [
    cj.Column.fromMap({
      'field': "title",
      'name': "TASK",
      'width': 220,
      'sortable': false,
      'formatter': TaskNameFormatter
    }),
    cj.Column.fromMap({
      'field': "duration",
      'name': "A",
      'width': 60,
      'sortable': false,
      'editor': 'TextEditor'
    }),
    cj.Column.fromMap({
      'field': "percentComplete",
      'name': 'Complete Rate',
      'width': 140,
      'sortable': true,
      'editor': 'DoubleEditor',
      'formatter': cj.PercentCompleteBarFormatter
    }),
    cj.Column.fromMap({'field': "finish", 'name': "C"}),
    cj.Column.fromMap({'field': "start", 'name': "D"}),
    cj.Column.fromMap({'field': "effortDriven", 'name': "E", 'width': 200})
  ];
//  cj.CheckboxSelectColumn checkboxCol=new cj.CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
//  column.insert(0,checkboxCol.getColumnDefinition());
  var opt = new cj.GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = true
    ..editable = true
    ..autoEdit = true
    //   ..enableAddRow=true
    ..leaveSpaceForNewRows = true
    ..frozenColumn = 0
    ..enableColumnReorder = true;

  cj.SlickGrid sg = cj.SlickGrid.fromOpt(el, makeData(50), column, opt);
  sg.setSelectionModel(cj.RowSelectionModel({'selectActiveRow': false}));
//  sg.registerPlugin(checkboxCol);
  sg.registerPlugin(AutoTooltips());

  //sg.setSelectionModel(new CellSelectionModel(sg.options));
  //args: {rows:[...], grid: SlickGrid }
  sg.onSelectedRowsChanged.subscribe((cj.EventData e, Map args) {
    querySelector('.right-pane')
      ..children.clear()
      ..appendText((args['rows'] as List).join(' '));
  });

  sg.onClick.subscribe((cj.EventData e, Map args) {
    if ((e.target as Element).classes.contains("toggle")) {
      Map item = _data[args['row']];
      if (!item['_collapsed']) {
        item['_collapsed'] = true;
      } else {
        item['_collapsed'] = false;
      }
      _data.invalidate();
      sg.invalidate();
      e.stopImmediatePropagation();
    }
  });

  return sg;
}

cj.TFormatter TaskNameFormatter =
    (int row, int cell, dynamic value, cj.Column columnDef, dataContext) {
  var spacer =
      "<span style='display:inline-block;height:1px;width:${15 *dataContext["indent"]}px'></span>";
  if (dataContext['_collapsed']) {
    return spacer + " <span class='toggle expand'></span>&nbsp;" + value;
  }
  if (row + 1 < _data.length &&
      _data[row + 1]['indent'] > _data[row]['indent']) {
    {
      return spacer + " <span class='toggle collapse'></span>&nbsp;" + value;
    }
  } else {
    return spacer + " <span class='toggle'></span>&nbsp;" + value;
  }
};
