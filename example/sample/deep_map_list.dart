import 'dart:html';
import 'package:slickdart/slick.dart' as grid;
import 'dart:math' as math;

void main() {
  var g = builldGrid();
  g.init();
}

grid.SlickGrid builldGrid() {
  Element el = querySelector('#grid');
  List<grid.Column> column = [
    grid.Column.fromMap({'name': "id", 'field': "title", 'sortable': true}),
    grid.Column.fromMap({'width': 120, 'name': "PercentComplete2", 'field': "percentComplete", 'sortable': true}),
    grid.Column.fromMap({'name': "Start", 'field': "start", 'sortable': true}),
    grid.Column.fromMap({'field': "finish"}),
    grid.Column.fromMap({'name': "TitleA", 'field': "title", 'sortable': true}),
    grid.Column.fromMap({'width': 120, 'name': "Complete", 'field': "percentComplete", 'sortable': true}),
    grid.Column.fromMap({'name': "Start A", 'field': "start", 'sortable': true}),
    grid.Column.fromMap({'name': "Finish A", 'field': "finish"}),
    grid.Column.fromMap({'name': "Finish B", 'field': "finish"}),
    grid.Column.fromMap({'name': "Title C", 'field': "title", 'sortable': true}),
  ];
  List data = [];
  for (var i = 0; i < 500; i++) {
    data.add({
      'title': i + 1,
      'duration': math.Random().nextInt(100).toString(),
      'percentComplete': math.Random().nextInt(10) * 100,
      'start': {'a': "01/01/200$i", 'b': 'ccc'},
      'finish': "01/05/2009",
      'finish1': "01/05/2009 $i",
      'finish2': "01/05/20$i",
      'finish3': "01/05/201$i",
      'finish4': "01/05/202$i",
      'effortDriven': (i % 5 == 0)
    });
  }
  grid.GridOptions opt = grid.GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = false
    ..enableColumnReorder = true
    ..dataItemColumnValueExtractor = mapExtract;
  grid.SlickGrid sg = grid.SlickGrid.fromOpt(el, data, column, opt);
  return sg;
}

mapExtract(Map row, grid.Column col) {
  if (col.field == 'start') return row['start']['a'];
  return row[col.field];
}
