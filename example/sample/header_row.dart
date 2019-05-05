import 'dart:html';
import 'package:slickdart/slick.dart' as cj;
import 'dart:math' as math;
import 'package:slickdart/plugin.dart';
//import 'package:throttle_debounce/throttle_debounce.dart';

var _data = new cj.FilteredList();
void main() {
  cj.SlickGrid grid = init();
  grid.init();
  querySelector('#reset').onClick.listen((e) {
    _data.clear();
    for (var i = 0; i < 50000; i++) {
      _data.add({
        'dtitle': new math.Random().nextInt(100).toString(),
        'duration': new math.Random().nextInt(100),
        'pc2': new math.Random().nextInt(10) * 100,
        'pc': (new math.Random().nextInt(10) * 100).toString(),
        'start': "01/01/2009",
        'finish': (new math.Random().nextInt(10) + 10).toString() + "/05/2013",
        'effortDriven': (i % 5 == 0)
      });
    }
    grid.invalidate();
  });
}

cj.SlickGrid init() {
  Element el = querySelector('#grid');
  List<cj.Column> column = [
    cj.Column.fromMap({
      'id': "title",
      'name': "Title(str)",
      'field': "dtitle",
      'sortable': true
    }),
    cj.Column.fromMap({
      'width': 120,
      'id': "duration",
      'name': "duration(num)",
      'field': "duration",
      'sortable': true,
      'editor': 'TextEditor'
    }),
    cj.Column.fromMap({
      'id': "%",
      'name': "int (num)",
      'field': "pc2",
      'sortable': true,
      'editor': 'TextEditor'
    }),
    cj.Column.fromMap({'id': "start", 'name': "finish", 'field': "finish"}),
    cj.Column.fromMap({
      'id': "%_2",
      'name': "String (number)",
      'field': "pc",
      'editor': 'TextEditor'
    }),
    cj.Column.fromMap({
      'id': "effort",
      'name': "(bool)",
      'field': "effortDriven",
      'width': 300
    })
  ];
  _data.clear();
  for (var i = 0; i < 55; i++) {
    _data.add({
      'dtitle': new math.Random().nextInt(100).toString(),
      'duration': new math.Random().nextInt(100),
      'pc2': new math.Random().nextInt(10) * 100,
      'pc': (new math.Random().nextInt(10) * 100).toString(),
      'start': "01/01/2009",
      'finish': (new math.Random().nextInt(10) + 10).toString() + "/05/2013",
      'effortDriven': (i % 5 == 0)
    });
  }
  Map opt = {
    'explicitInitialization': false,
    'multiColumnSort': true,
    'editable': true,
    'autoEdit': true,
    'frozenColumn': 1,
    'showHeaderRow': true,
    'headerRowHeight': 25
  };
  cj.SlickGrid sg = new cj.SlickGrid(el, _data, column, opt);
  sg.setSelectionModel(new cj.RowSelectionModel({'selectActiveRow': false}));
  sg.registerPlugin(new AutoTooltips());

  sg.onHeaderRowCellRendered.subscribe((cj.EventData e, Map args) {
    Element headerEl = args['node'];
    headerEl.children.clear();
    cj.Column col = args['column'];
    if (col.id == '_checkbox_selector') return;

    var inputEl = InputElement()
      ..dataset['columnId'] = col.field
      ..onInput.listen((Event ke) {
        var searchStr = (ke.currentTarget as InputElement).value;
        if (col.field == 'effortDriven' && searchStr.isNotEmpty) {
          _data.addKeyword(
              col.field, searchStr.toLowerCase() == 'true' ? true : false);
        } else {
          _data.addKeyword(col.field, searchStr);
        }
        sg.invalidate();
      });
    headerEl.append(inputEl);
  });
  sg.onSort.subscribe(cj.basicSorter);
  return sg;
}
