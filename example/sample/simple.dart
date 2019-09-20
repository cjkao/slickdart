import 'dart:html';
import 'package:slickdart/slick.dart' as grid;

import 'dart:math' as math;

void main() {
  var columns = <grid.Column>[
    grid.Column.fromMap({'name': "id", 'field': "title", 'sortable': true}),
    grid.Column.fromMap({'width': 120, 'name': "percentComplete2", 'field': "percentComplete", 'sortable': true}),
    grid.Column.fromMap({'name': "start3", 'field': "start", 'sortable': true}),
    grid.Column.fromMap({'field': "finish"}),
    grid.Column.fromMap({'name': "5Title1", 'field': "title", 'sortable': true}),
    grid.Column.fromMap({'width': 120, 'name': "6complete", 'field': "percentComplete", 'sortable': true}),
    grid.Column.fromMap({'name': "7start", 'field': "start", 'sortable': true}),
    grid.Column.fromMap({'name': "8finish", 'field': "finish"}),
    grid.Column.fromMap({'name': "9finish", 'field': "finish"}),
    grid.Column.fromMap({'name': "10 Title1", 'field': "title", 'sortable': true}),
    grid.Column.fromMap({'width': 120, 'name': "11 percentComplete", 'field': "percentComplete", 'sortable': true}),
    grid.Column.fromMap({'name': "12 start", 'field': "start", 'sortable': true}),
    grid.Column.fromMap({'name': "13 finish", 'field': "finish"}),
    grid.Column.fromMap({'name': "14 Title1", 'field': "title", 'sortable': true}),
    grid.Column.fromMap({'width': 120, 'name': "15 percentComplete", 'field': "percentComplete", 'sortable': true}),
    grid.Column.fromMap({'name': "16 start", 'field': "start", 'sortable': true}),
    grid.Column.fromMap({'name': "17 finish", 'field': "finish1"}),
    grid.Column.fromMap({'name': "18 finish", 'field': "finish2"}),
    grid.Column.fromMap({'name': "19 finish", 'field': "finish3"}),
    grid.Column.fromMap({'name': "20 finish", 'field': "finish4"})
  ];
  var g = init();
  g.init();
  columns.forEach((grid.Column _) {
    _.minWidth = 60;
    _.maxWidth = 200;
  });
  g.setColumns(columns);
  g.invalidate();
  g.render();
}

grid.SlickGrid init() {
  Element el = querySelector('#grid');

  List data = [];
  for (var i = 0; i < 500; i++) {
    data.add({
      'title': i + 1,
      'duration': math.Random().nextInt(100).toString(),
      'percentComplete': math.Random().nextInt(10) * 100,
      'start': "01/01/2009",
      'finish': "01/05/2009",
      'finish1': "01/05/2009 $i",
      'finish2': "01/05/20$i",
      'finish3': "01/05/201$i",
      'finish4': "01/05/202$i",
      'effortDriven': (i % 5 == 0)
    });
  }
  var opt = grid.GridOptions()
    ..enableColumnReorder = true
    ..explicitInitialization = false
    ..multiColumnSort = false;
  grid.SlickGrid sg = grid.SlickGrid.fromOpt(el, data, [], opt);
  sg.onSort.subscribe(grid.basicSorter);

  return sg;
}
