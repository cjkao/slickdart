import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'package:slickdart/plugin.dart';

import 'dart:math' as math;
import 'dart:async';

main() async {
  for (int i = 0; i < 11110; ++i) {
    await Future.delayed(Duration(milliseconds: 1000), () {
      build();
    });
    querySelector('#rec').text = '$i';
  }
}

build() {
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
    grid.Column.fromMap({'name': "20 finish", 'field': "finish4"}),
  ];
  Element el = querySelector('#grid');
  var parent = el.parent;
  Element nel = DivElement();
  el.remove();
  el.replaceWith(nel);
  nel.id = 'grid';
  parent.children.add(nel);
  el = nel;
  List data = [];
  for (var i = 0; i < 5; i++) {
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
    ..enableColumnReorder = true
    ..multiColumnSort = false;
  grid.SlickGrid sg = grid.SlickGrid.fromOpt(el, data, columns, opt);
  var rowModel = grid.RowSelectionModel({'selectActiveRow': true});
  sg.setSelectionModel(rowModel);
  var tip = AutoTooltips();
  sg.registerPlugin(tip);
  sg.init();
  sg.onSort.subscribe(grid.basicSorter);

  sg.invalidate();
  sg.render();
  Future.delayed(Duration(milliseconds: 1000), () {
    sg.unSubscribe();
  });
//  data.clear();
}
