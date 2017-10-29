import 'dart:html';
import 'dart:convert';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;
import 'package:slickdart/slick_cell_selection.dart' as cellMode;
import 'package:slickdart/slick_column.dart';

void main() {
  grid.SlickGrid g = init();
  g.init();
//  print (g.$headerScroller.querySelectorAll('.slick-header-column').length);
  querySelector('#reset').onClick.listen((e) {
    List _data = [];
    for (var i = 0; i < 50000; i++) {
      _data.add({
        'dtitle': new math.Random().nextInt(1000).toString(),
        'duration': new math.Random().nextInt(1000).toString(),
        'pc': new math.Random().nextInt(100),
        'effortDriven': (i % 5 == 0),
        'link': '$i'
      });
    }
    g.data.clear();
    g.data.addAll(_data);
    g.invalidate();
    g.render();
  });
}

grid.SlickGrid init() {
  Element el = querySelector('#grid');
  List<grid.Column> column = [
    new grid.Column.fromMap({
      'id': "title",
      'name': "format from Class",
      'field': "dtitle",
      'sortable': true,
      'editor': 'TextEditor',
      'formatter':  SuperFormatter.mySpecial
    }),
    new grid.Column()
      ..formatter = LinkFormatter
      ..name = "LINK"
      ..id = "LINK"
      ..field = 'link',

    new grid.Column.fromMap(
        {'width': 120, 'id': "duration", 'name': "duration", 'field': "duration", 'sortable': true}),
    new grid.Column.fromMap({
      'id': "%",
      'name': "percentComplete",
      'field': "pc",
      'sortable': true,
      'formatter': grid.PercentCompleteBarFormatter
    }),
    new grid.Column.fromMap({
      'id': "effort-driven",
      'name': "Effort Driven",
      'sortable': false,
      'width': 80,
      'minWidth': 20,
      'maxWidth': 80,
      'cssClass': "cell-effort-driven",
      'field': "effortDriven",
      'formatter': grid.CheckmarkFormatter
    }),

    new grid.Column.fromMap(
        {'name': "Btn Driven", 'sortable': false, 'width': 80, 'field': "effortDriven", 'formatter': ButtonFormatter})

    // new grid.Column.fromMap ({'id': "start", 'name': "finish", 'field': "finish"})
  ];
  List data = [];
  for (var i = 0; i < 50000; i++) {
    data.add({
      'dtitle': i.toString(),
      'duration': new math.Random().nextInt(100).toString(),
      'pc': new math.Random().nextInt(100),
      'effortDriven': (i % 5 == 0),
      'link': i + new math.Random().nextInt(10)
    });
  }
  Map opt = {
    'explicitInitialization': false,
    'multiColumnSort': true,
    'editable': true,
  };
  grid.SlickGrid sg = new grid.SlickGrid(el, data, column, opt);
  var model = new cellMode.CellSelectionModel(sg.options);

  sg.setSelectionModel(model);
  sg.onClick.subscribe((grid.EventData e, Map args) {
    print(args);
    grid.Column col = sg.getColumns()[args['cell']];
    if (e.target is InputElement) {
      print('it is button');
      print(col);
    }
  });
  sg.onSort.subscribe(grid.basicSorter);
  return sg;
}

class SuperFormatter {
  static TFormatter mySpecial= (int row, int cell, dynamic value, grid.Column columnDef, dataContext) {
    /**demo code for ser/deser */
    var colStr = JSON.encode(columnDef);
    new grid.Column.fromJSON(colStr);
    /** end */
    return "$value";
  };

}

/// see [grid.TFormatter]
SuperFormatter2(int row, int cell, dynamic value, grid.Column columnDef, dataContext) {
  var colStr = JSON.encode(columnDef.toString());
  // grid.Column col = new grid.Column.fromJSON(colStr);
  return "$value";
}

/// see [grid.TFormatter]
String ButtonFormatter(int row, int cell, dynamic value, grid.Column columnDef, dataContext) {
  if (row % 4 == 0) return 'T';
  return '<input type="button" value="$value" style="width:100%;padding:0;">';
}

/// see [grid.TFormatter]
String LinkFormatter(int row, int cell, dynamic value, grid.Column columnDef, dataContext) {
  if (value % 5 == 0) return "<a href='#'>Link - $value</a>";
  if (value % 3 == 0) return "<div style='color:red;text-align:right;width:100%;'>$value</div>";
  return "$value";
}
