import 'dart:html';
import 'dart:math' as math;
import "package:slickdart/slick.dart";
import 'package:logging/logging.dart';

Map<String, Map<String, int>> getMeta(int row) {
  if (row % 3 == 0) {
    return {
      MetaList.COLUMN: {'duration': 2}
    };
  }
  return {};
}

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  SlickGrid g = buildGrid();
  g.init();
  querySelector('#reset').onClick.listen((e) {
    List _data = [];
    for (var i = 0; i < 500000; i++) {
      _data.add(
          {'idi': i, 'title': math.Random().nextInt(1000).toString(), 'duration': math.Random().nextInt(1000).toString(), 'pc': i});
    }
    var metaList = MetaList(_data, getMeta);
    g.data = metaList;
    g.invalidate();
    g.render();
  });
  querySelector('#commit').onClick.listen((e) {
    g.getEditorLock().commitCurrentEdit();
  });
}

SlickGrid buildGrid() {
  Element el = querySelector('#grid');
  List<Column> column = ColumnList.fromMap([
    {'width': 130, 'field': "idi", 'name': 'ID', 'sortable': true, 'editor': 'TextEditor'},
    {'width': 120, 'field': "duration", 'sortable': true, 'editor': 'TextEditor'},
    {'field': "pc", 'sortable': true},
    {'width': 400, 'field': "finish"}
  ]);
  //CheckboxSelectColumn checkboxCol= CheckboxSelectColumn({   'cssClass': "slick-cell-checkboxsel" });
  //column.insert(0,checkboxCol.getColumnDefinition());
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
  var metaList = MetaList(data, getMeta);
  var opt = GridOptions()
    ..explicitInitialization = false
    ..multiColumnSort = false
    ..multiSelect = false
    ..editable = true
    ..autoEdit = false
    ..enableColumnReorder = true;
//    ..frozenColumn = 0;
  SlickGrid sg = SlickGrid.fromOpt(el, metaList, column, opt);
  var cellSelectModel = CellSelectionModel();
  cellSelectModel.onSelectedRangesChanged.subscribe((var e, args) {
    cellSelectModel.getSelectedRanges().forEach(print);
  });
  sg.setSelectionModel(cellSelectModel);

  return sg;
}
